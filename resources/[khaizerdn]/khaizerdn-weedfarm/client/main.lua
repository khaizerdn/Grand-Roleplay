local spawnedEntities = {}
local isHarvesting = false

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
end

local function spawnPlant(plant)
    loadModel(Config.PlantModel)
    local coords = plant.coords

    -- Create plant object
    local obj = CreateObject(Config.PlantModel, coords.x, coords.y, coords.z - 1.0, false, false, false)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)

    -- Create the interaction zone
    local zoneId = "weedplant_" .. plant.id
    lib.zones.sphere({
        coords = coords,
        radius = 1.5,
        debug = false,
        inside = function()
            if IsControlJustReleased(0, 38) then -- E key press
                TriggerServerEvent("weedfarm:harvest", plant.id)
                lib.hideTextUI()
            end
        end,
        onEnter = function()
            if DoesEntityExist(obj) then -- Check if the weed prop exists
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
    
    -- Store the entity and zone for later removal
    spawnedEntities[plant.id] = {
        entity = obj,
        zoneId = zoneId
    }
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
    local blip = AddBlipForCoord(Config.Zone.center)
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
end)

