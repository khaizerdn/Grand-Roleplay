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

-- Update plants when server tells client to spawn
RegisterNetEvent("weedfarm:updatePlants", function(plants)
    -- Cleanup existing plants
    for _, info in pairs(spawnedEntities) do
        if DoesEntityExist(info.entity) then
            DeleteEntity(info.entity)
        end
    end
    spawnedEntities = {}

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
