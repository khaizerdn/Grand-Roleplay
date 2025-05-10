local config = require 'shared.config'

-- Placeholder function to get vehicle name (replace with your framework's equivalent)
local function getVehicleName(model)
    -- Example for QBcore: return QBCore.Shared.Vehicles[model]?.name or 'Vehicle'
    return 'Vehicle'
end

-- Export to give a key item to a player
exports('GiveKey', function(playerId, vehicle, temporary)
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate (no spaces, uppercase)
    local model = GetEntityModel(vehicle)
    local vehicleName = getVehicleName(model)
    local metadata = {
        plate = plate,
        model = model,
        description = rawPlate,
        temporary = temporary or false
    }
    exports.ox_inventory:AddItem(playerId, 'vehicle_key', 1, metadata)
end)

-- Server event to toggle vehicle lock
RegisterNetEvent('vehiclekeys:server:attemptToggleLock', function(netId, action)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or GetEntityType(vehicle) ~= 2 then return end -- Ensure it's a vehicle
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate
    local count = exports.ox_inventory:Search(src, 'count', 'vehicle_key', {plate = plate})
    if count > 0 then
        local newState = action == 'lock' and 2 or 1 -- 2 = locked, 1 = unlocked
        Entity(vehicle).state:set('doorslockstate', newState, true)
        TriggerClientEvent('vehiclekeys:client:toggleLock', src, true, newState, netId)
    else
        TriggerClientEvent('vehiclekeys:client:toggleLock', src, false)
    end
end)

-- Admin command to give key for closest vehicle
lib.addCommand('adminkey', {
    help = 'Give yourself a key for the closest vehicle',
    restricted = 'group.admin', -- Restrict to admins
}, function(source)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = lib.getClosestVehicle(playerCoords, config.vehicleMaximumLockingDistance, true)
    if not vehicle then
        exports.qbx_core:Notify(source, 'No vehicle nearby', 'error')
        return
    end
    exports['khaizerdn-vehiclekeys']:GiveKey(source, vehicle)
    exports.qbx_core:Notify(source, 'Received key for vehicle', 'success')
end)

-- Callback to check if player has key for vehicle
lib.callback.register('vehiclekeys:server:hasKey', function(source, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or GetEntityType(vehicle) ~= 2 then return false end
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate
    local count = exports.ox_inventory:Search(source, 'count', 'vehicle_key', {plate = plate})
    return count > 0
end)

lib.callback.register('vehiclekeys:server:hasKeyPlateOnly', function(source, plate)
    local count = exports.ox_inventory:Search(source, 'count', 'vehicle_key', { plate = plate })
    return count > 0
end)

local function sendPlayerKeys(playerId)
    local keys = exports.ox_inventory:Search(playerId, 'slots', 'vehicle_key')
    local plates = {}
    for _, item in ipairs(keys) do
        if item.metadata and item.metadata.plate then
            plates[#plates+1] = item.metadata.plate
        end
    end
    TriggerClientEvent('vehiclekeys:client:updateOwnedPlates', playerId, plates)
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        if pid then
            exports['khaizerdn-vehiclekeys']:UpdatePlayerKeys(pid)
        end
    end
end)

-- On player join or manually trigger it when needed
AddEventHandler('playerJoining', function()
    local src = source
    sendPlayerKeys(src)
end)

RegisterNetEvent('vehiclekeys:server:syncOwnedKeys', function()
    local src = source
    exports['khaizerdn-vehiclekeys']:UpdatePlayerKeys(src)
end)

local function isPlayer(source)
    return type(source) == 'number' and GetPlayerPed(source) ~= 0
end

local function tryUpdateKeySync(source, item)
    if isPlayer(source) and item.name == 'vehicle_key' then
        exports['khaizerdn-vehiclekeys']:UpdatePlayerKeys(source)
    end
end

AddEventHandler('ox_inventory:updateInventory', function(source, inventory)
    if inventory and inventory.type == 'player' then
        exports['khaizerdn-vehiclekeys']:UpdatePlayerKeys(source)
    end
end)

RegisterNetEvent('vehiclekeys:server:refreshKeys', function()
    local src = source
    exports['khaizerdn-vehiclekeys']:UpdatePlayerKeys(src)
end)


-- Export or event you can call from elsewhere (e.g., after giving/removing key)
exports('UpdatePlayerKeys', sendPlayerKeys)