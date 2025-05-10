-- Check if a player has a key for a vehicle
exports('HasKeys', function(src, vehicle)
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate
    local count = exports.ox_inventory:Search(src, 'count', 'vehicle_key', {plate = plate})
    return count > 0
end)

-- Give a key to a player (wrapper for GiveKey export)
exports('GiveKeys', function(src, vehicle, skipNotification)
    exports['vehiclekeys']:GiveKey(src, vehicle)
    if not skipNotification then
        exports.qbx_core:Notify(src, 'Received key for vehicle', 'success')
    end
    return true
end)

-- Remove a key from a player
exports('RemoveKeys', function(src, vehicle, skipNotification)
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate
    local items = exports.ox_inventory:Search(src, 'items', 'vehicle_key', {plate = plate})
    if #items > 0 then
        exports.ox_inventory:RemoveItem(src, 'vehicle_key', 1, items[1].metadata, items[1].slot)
        if not skipNotification then
            exports.qbx_core:Notify(src, 'Vehicle key removed', 'success')
        end
        return true
    end
    return false
end)