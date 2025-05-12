local QBCore = exports['qb-core']:GetCoreObject()
local activePlants = {}

-- Function to spawn all plants
local function spawnPlants()
    activePlants = {}
    for i, coords in ipairs(Config.PlantSpawns) do
        local isHarvested = math.random() < Config.RandomHarvestChance
        local respawnTime = nil

        if isHarvested then
            local randomDelay = math.random(1, Config.RespawnSeconds)
            respawnTime = os.time() + randomDelay
        end

        activePlants[i] = {
            id = i,
            coords = coords,
            harvested = isHarvested,
            respawnTime = respawnTime
        }
    end

    TriggerClientEvent("weedfarm:updatePlants", -1, activePlants)
end

-- Handle plant harvest by a player
RegisterNetEvent("weedfarm:harvest", function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not activePlants[id] or activePlants[id].harvested then return end

    activePlants[id].harvested = true
    activePlants[id].respawnTime = os.time() + Config.RespawnSeconds
    TriggerClientEvent("weedfarm:removePlant", -1, id)

    -- Give the player a weed item on harvest
    if Player then
        Player.Functions.AddItem(Config.HarvestItem, 1)
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Weed Farm",
            description = "You harvested some weed!",
            type = "success"
        })
    end
end)

-- Player requests the current plant data
RegisterNetEvent("weedfarm:requestPlants", function()
    local src = source
    TriggerClientEvent("weedfarm:updatePlants", src, activePlants)
end)

CreateThread(function()
    while true do
        local nextRespawnTime = math.huge -- Start with a very large number
        local updated = false

        -- Find the nearest respawn time
        for _, plant in pairs(activePlants) do
            if plant.harvested and plant.respawnTime then
                if plant.respawnTime < os.time() then
                    -- Respawn the plant immediately
                    plant.harvested = false
                    plant.respawnTime = nil
                    updated = true
                else
                    -- Track the earliest upcoming respawn time
                    nextRespawnTime = math.min(nextRespawnTime, plant.respawnTime)
                end
            end
        end

        -- If something was updated, send the new plant data
        if updated then
            TriggerClientEvent("weedfarm:updatePlants", -1, activePlants)
        end

        -- Wait until the next respawn event
        local waitTime = nextRespawnTime - os.time()
        if waitTime > 0 then
            Wait(waitTime * 1000) -- Convert seconds to milliseconds
        else
            -- If there's no respawn time left, wait for 1 second before re-checking
            Wait(1000)
        end
    end
end)

-- Initial spawn on resource start
AddEventHandler("onResourceStart", function(res)
    if res == GetCurrentResourceName() then
        Wait(1000)
        spawnPlants()
    end
end)

RegisterNetEvent("weedfarm:debugResetPlants", function()
    print("[Debug] Resetting all plants")
    spawnPlants() -- resets all plants to unharvested
end)
