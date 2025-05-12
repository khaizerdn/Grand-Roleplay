local QBCore = exports['qb-core']:GetCoreObject()
local activePlants = {}

-- Function to spawn all plants
local function spawnPlants()
    activePlants = {}
    for i, coords in ipairs(Config.PlantSpawns) do
        activePlants[i] = {
            id = i,
            coords = coords,
            harvested = false
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

-- Spawn plants at regular intervals
CreateThread(function()
    while true do
        Wait(Config.SpawnInterval)
        spawnPlants()
    end
end)

-- Initial spawn on resource start
AddEventHandler("onResourceStart", function(res)
    if res == GetCurrentResourceName() then
        Wait(1000)
        spawnPlants()
    end
end)
