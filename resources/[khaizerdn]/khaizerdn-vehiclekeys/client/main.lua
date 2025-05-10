local config = require 'shared.config'
local ownedPlates = {}

local function getVehicleWithinRange(coords, maxDistance)
    local vehicles = GetGamePool('CVehicle')
    local closestVehicle = nil
    local closestDistance = maxDistance

    for _, veh in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(veh)
        local dist = #(vehCoords - coords)
        if dist <= closestDistance then
            closestVehicle = veh
            closestDistance = dist
        end
    end

    return closestVehicle
end

RegisterNetEvent('vehiclekeys:client:updateOwnedPlates', function(plates)
    ownedPlates = {}
    for _, plate in ipairs(plates) do
        ownedPlates[plate] = true
    end
end)

local function hasKeyForPlate(plate)
    return ownedPlates[plate] == true
end

local function findOwnedVehicleNearby(coords, maxDistance)
    local vehicles = GetGamePool('CVehicle')
    for _, veh in ipairs(vehicles) do
        local dist = #(GetEntityCoords(veh) - coords)
        if dist <= maxDistance then
            local plate = string.upper(string.gsub(GetVehicleNumberPlateText(veh), "%s+", ""))
            if hasKeyForPlate(plate) then
                return veh
            end
        end
    end
    return nil
end

toggleLockBind = lib.addKeybind({
    name = 'togglevehiclelock',
    description = 'Toggle vehicle lock',
    defaultKey = 'L',
    onPressed = function()
        toggleLockBind:disable(true)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = findOwnedVehicleNearby(playerCoords, config.vehicleMaximumLockingDistance)

        if vehicle then
            local netId = NetworkGetNetworkIdFromEntity(vehicle)
            local lockStatus = GetVehicleDoorLockStatus(vehicle)
            local action = lockStatus == 2 and 'unlock' or 'lock'
            TriggerServerEvent('vehiclekeys:server:attemptToggleLock', netId, action)
        else
            exports.qbx_core:Notify('No owned vehicle nearby', 'error')
        end

        Wait(1000)
        toggleLockBind:disable(false)
    end
})

-- Handle toggle lock response from server
RegisterNetEvent('vehiclekeys:client:toggleLock', function(success, newState)
    if success then
        local vehicle = findOwnedVehicleNearby(GetEntityCoords(PlayerPedId()), config.vehicleMaximumLockingDistance)
        if vehicle then
            lib.playAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, 1600, 49, 0, false, false, false)
            SetVehicleLights(vehicle, 2)
            Wait(250)
            SetVehicleLights(vehicle, 1)
            Wait(200)
            SetVehicleLights(vehicle, 0)
            local message = newState == 2 and 'Vehicle locked' or 'Vehicle unlocked'
            exports.qbx_core:Notify(message)
        end
    else
        exports.qbx_core:Notify('You don\'t have the key for this vehicle', 'error')
    end
end)

-- Sync vehicle lock state with state bag
AddStateBagChangeHandler('doorslockstate', nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if entity and entity ~= 0 then
        SetVehicleDoorsLocked(entity, value)
    end
end)

-- Check if player has key when in driver seat to allow engine start
lib.onCache('seat', function(seat)
    if seat ~= -1 then return end -- Only handle driver seat
    local vehicle = cache.vehicle
    if not vehicle then return end

    CreateThread(function()
        while cache.seat == -1 and cache.vehicle == vehicle do
            local netId = NetworkGetNetworkIdFromEntity(vehicle)
            local hasKey = lib.callback.await('vehiclekeys:server:hasKey', false, netId)
            if not hasKey then
                -- Disable engine start controls
                DisableControlAction(0, 71, true) -- INPUT_VEH_ACCELERATE (used to start engine)
                SetVehicleEngineOn(vehicle, false, true, true)
                if IsControlJustPressed(0, 71) then
                    exports.qbx_core:Notify('You need the key to start the vehicle', 'error')
                end
            else
                -- Re-enable engine controls if key is present
                DisableControlAction(0, 71, false)
            end
            Wait(0)
        end
        -- Re-enable controls when leaving driver seat
        DisableControlAction(0, 71, false)
    end)
end)


-- Ask server to send owned plates again
RegisterNetEvent('vehiclekeys:client:requestKeySync', function()
    TriggerServerEvent('vehiclekeys:server:syncOwnedKeys')
end)

-- Automatically request keys when resource starts
CreateThread(function()
    TriggerEvent('vehiclekeys:client:requestKeySync')
end)