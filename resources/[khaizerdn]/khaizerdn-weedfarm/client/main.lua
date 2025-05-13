local spawnedEntities = {}
local plantZones = {}
local isHarvesting = false
local cancelKey = 73  -- The 'X' key (you can change this to another key if you want)


local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function spawnPlant(plant)
    loadModel(Config.PlantModel)
    local coords = plant.coords

    -- Delete old zone if it exists
    if plantZones[plant.id] then
        plantZones[plant.id]:remove()
        plantZones[plant.id] = nil
    end

    -- Create plant object
    local obj = CreateObject(Config.PlantModel, coords.x, coords.y, coords.z - 1.0, false, false, false)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)

    -- Create the interaction zone
    local zone = lib.zones.sphere({
        coords = coords,
        radius = 0.7,
        debug = false,
        inside = function()
            if IsControlJustReleased(0, 38) and not isHarvesting then
                lib.hideTextUI()
                isHarvesting = true

                lib.callback('weedfarm:canCarryItem', false, function(canCarry)
                    if not canCarry then
                        lib.notify({
                            title = 'Weed Farm',
                            description = 'Your inventory is full!',
                            type = 'error'
                        })
                        isHarvesting = false
                        return
                    end

                    local ped = PlayerPedId()

                    -- Immediately check for cancel key before any animation starts
                    if IsControlJustPressed(0, cancelKey) then
                        lib.notify({
                            title = 'Weed Farm',
                            description = 'Harvest canceled.',
                            type = 'error'
                        })
                        isHarvesting = false
                        return
                    end

                    -- Play the enter animation
                    lib.playAnim(ped, "amb@world_human_gardener_plant@male@enter", "enter", 6.0, -6.0, 2700)
                    Wait(2700)
                    lib.playAnim(ped, "amb@world_human_gardener_plant@male@base", "base", 6.0, -6.0, 5000)

                    -- Track time to allow cancel checking continuously
                    local startTime = GetGameTimer()
                    local duration = 5000 -- Duration of harvesting animation in ms

                    while GetGameTimer() - startTime < duration do
                        Wait(0) -- Ensure continuous checking for cancel key

                        -- Check if cancel key is pressed during the harvest process
                        if IsControlJustPressed(0, cancelKey) then
                            lib.notify({
                                title = 'Weed Farm',
                                description = 'Harvest canceled.',
                                type = 'error'
                            })
                            isHarvesting = false
                            lib.playAnim(ped, "amb@world_human_gardener_plant@male@exit", "exit", 2.2, -2.2, 2000)
                            Wait(2700)
                            lib.hideTextUI()
                            return
                        end
                    end

                    -- Completed harvesting
                    lib.playAnim(ped, "amb@world_human_gardener_plant@male@exit", "exit", 2.2, -2.2, 2000)
                    Wait(2700)
                    TriggerServerEvent("weedfarm:harvest", plant.id)
                    lib.hideTextUI()
                    isHarvesting = false
                end)
            end
        end,
        onEnter = function()
            if DoesEntityExist(obj) then
                lib.showTextUI('[E] Harvest Weed', {
                    icon = 'leaf',
                    position = 'left-center'
                })
            end
        end,
        onExit = function()
            lib.hideTextUI()
        end,
    })

    spawnedEntities[plant.id] = { entity = obj }
    plantZones[plant.id] = zone
end


local function isPointInPoly(point, poly)
    local x, y = point.x, point.y
    local inside = false
    for i = 1, #poly do
        local j = i % #poly + 1
        local xi, yi = poly[i].x, poly[i].y
        local xj, yj = poly[j].x, poly[j].y

        if ((yi > y) ~= (yj > y)) and
           (x < (xj - xi) * (y - yi) / (yj - yi + 0.00001) + xi) then
            inside = not inside
        end
    end
    return inside
end

local function tryDeleteEntity(entity)
    if not DoesEntityExist(entity) then return end

    -- Request control
    NetworkRequestControlOfEntity(entity)
    local timeout = GetGameTimer() + 2000
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
        Wait(10)
        NetworkRequestControlOfEntity(entity)
    end

    -- Force ownership and delete
    if NetworkHasControlOfEntity(entity) then
        SetEntityAsMissionEntity(entity, true, true) -- this is the key line
        DeleteEntity(entity)
        if DoesEntityExist(entity) then
            print("[Cleanup] Failed to delete entity even with control.")
        else
            print("[Cleanup] Successfully deleted entity.")
        end
    else
        print("[Cleanup] Could not gain control of entity.")
    end
end

local function removeOrphanedPlants()
    local modelHash = Config.PlantModel
    local zonePoly = Config.Zone.points
    local handle, obj = FindFirstObject()
    local success
    local removedCount = 0

    repeat
        if DoesEntityExist(obj) and GetEntityModel(obj) == modelHash then
            local coords = GetEntityCoords(obj)
            if isPointInPoly(coords, zonePoly) then
                tryDeleteEntity(obj)
                removedCount = removedCount + 1
            end
        end
        success, obj = FindNextObject(handle)
    until not success

    EndFindObject(handle)
    print("[Cleanup] Total removed: " .. removedCount)
end

-- Update plants when server tells client to spawn
RegisterNetEvent("weedfarm:updatePlants", function(plants)
    -- Cleanup existing plants
    for _, info in pairs(spawnedEntities) do
        if DoesEntityExist(info.entity) then
            DeleteEntity(info.entity)
        end
    end
    spawnedEntities = {}

    removeOrphanedPlants()

    -- Spawn new plants
    for _, plant in pairs(plants) do
        if not plant.harvested then
            spawnPlant(plant)
        end
    end
end)

-- Remove specific plant from the client side (when harvested)
RegisterNetEvent("weedfarm:removePlant", function(id)
    local plant = spawnedEntities[id]
    if plant then
        if DoesEntityExist(plant.entity) then
            DeleteEntity(plant.entity)
        end
        spawnedEntities[id] = nil
    end
end)

CreateThread(function()
    lib.zones.poly({
        points = Config.Zone.points,
        thickness = 20.0,
        debug = false,
        inside = function()
        end,        
        onEnter = function()
            print("Entered weed farm")
        end,
        onExit = function()
            print("Exited weed farm")
        end
    })
end)

-- Request synced plants when player loads in
CreateThread(function()
    TriggerServerEvent("weedfarm:requestPlants")

    -- Create blip for weed farm location
    local blip = AddBlipForCoord(Config.Zone.blip)
    SetBlipSprite(blip, 496)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Weed Farm")
    EndTextCommandSetBlipName(blip)
end)

RegisterCommand("cleanupplants", function()
    removeOrphanedPlants()
    TriggerServerEvent("weedfarm:debugResetPlants")
end)

