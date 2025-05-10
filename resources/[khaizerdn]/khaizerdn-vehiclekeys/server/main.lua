local config = require 'shared.config'

-- Placeholder function to get vehicle name (replace with your framework's equivalent)
local function getVehicleName(model)
    -- Example for QBcore: return QBCore.Shared.Vehicles[model]?.name or 'Vehicle'
    return 'Vehicle'
end

-- Export to give a key item to a player
exports('GiveKey', function(playerId, vehicle)
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate (no spaces, uppercase)
    local model = GetEntityModel(vehicle)
    local vehicleName = getVehicleName(model)
    local metadata = {
        plate = plate,
        model = model,
        label = ("Key for %s (%s)"):format(vehicleName, rawPlate)
    }
    exports.ox_inventory:AddItem(playerId, 'vehicle_key', 1, metadata)
end)

-- Server event to toggle vehicle lock
RegisterNetEvent('vehiclekeys:server:attemptToggleLock', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or GetEntityType(vehicle) ~= 2 then return end -- Ensure it's a vehicle
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate
    local count = exports.ox_inventory:Search(src, 'count', 'vehicle_key', {plate = plate})
    if count > 0 then
        local currentState = Entity(vehicle).state.doorslockstate or 1
        local newState = currentState == 1 and 2 or 1 -- Toggle: 1 (unlocked) to 2 (locked) or vice versa
        Entity(vehicle).state:set('doorslockstate', newState, true)
        TriggerClientEvent('vehiclekeys:client:toggleLock', src, true, newState)
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