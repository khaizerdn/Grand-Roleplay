---@param vehicleId integer
---@param modelName string
local function setVehicleStateToOut(vehicleId, vehicle, modelName)
    local depotPrice = Config.calculateImpoundFee(vehicleId, modelName) or 0
    exports.qbx_vehicles:SaveVehicle(vehicle, {
        state = VehicleState.OUT,
        depotPrice = depotPrice
    })
    Entity(vehicle).state:set('vehicleid', vehicleId, true) -- Ensure vehicleid is set
    Entity(vehicle).state:set('garage', nil, true) -- Clear garage state
    lib.print.debug('Set vehicle state to OUT:', vehicleId, 'Model:', modelName, 'Depot Price:', depotPrice)
end

---@param source number
---@param vehicleId integer
---@param garageName string
---@param accessPointIndex integer
---@return number? netId
lib.callback.register('qbx_garages:server:spawnVehicle', function (source, vehicleId, garageName, accessPointIndex)
    local garage = Garages[garageName]
    local garageType = GetGarageType(garageName)

    local filter = GetPlayerVehicleFilter(source, garageName)
    local playerVehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId, filter)
    if not playerVehicle then
        exports.qbx_core:Notify(source, locale('error.not_owned'), 'error')
        return
    end
    if garageType == GarageType.DEPOT and FindPlateOnServer(playerVehicle.props.plate) then
        return exports.qbx_core:Notify(source, locale('error.not_impound'), 'error', 5000)
    end

    -- Use specific spawn point for impound lot, otherwise use parked_position
    local spawnCoords
    if garageType == GarageType.DEPOT then
        local accessPoint = garage.accessPoints[accessPointIndex]
        if not accessPoint.spawn then
            exports.qbx_core:Notify(source, locale('error.no_spawn_position'), 'error')
            return
        end
        spawnCoords = accessPoint.spawn
    else
        if not playerVehicle.parked_position then
            exports.qbx_core:Notify(source, locale('error.no_spawn_position'), 'error')
            return
        end
        spawnCoords = vec4(playerVehicle.parked_position.x, playerVehicle.parked_position.y, playerVehicle.parked_position.z, playerVehicle.parked_position.w)
    end

    if Config.distanceCheck then
        local vec3Coords = vec3(spawnCoords.x, spawnCoords.y, spawnCoords.z)
        local nearbyVehicle = lib.getClosestVehicle(vec3Coords, Config.distanceCheck, false)
        if nearbyVehicle then
            exports.qbx_core:Notify(source, locale('error.no_space'), 'error')
            return
        end
    end

    local warpPed = Config.warpInVehicle and GetPlayerPed(source)
    local netId, veh = qbx.spawnVehicle({ spawnSource = spawnCoords, model = playerVehicle.props.model, props = playerVehicle.props, warp = warpPed})

    if Config.doorsLocked then
        if GetResourceState('qbx_vehiclekeys') == 'started' then
            TriggerEvent('qb-vehiclekeys:server:setVehLockState', netId, 2)
        else
            SetVehicleDoorsLocked(veh, 2)
        end
    end

    TriggerClientEvent('vehiclekeys:client:SetOwner', source, playerVehicle.props.plate)

    Entity(veh).state:set('vehicleid', vehicleId, true)
    setVehicleStateToOut(vehicleId, veh, playerVehicle.modelName)
    TriggerEvent('qbx_garages:server:vehicleSpawned', veh)
    lib.print.debug('Vehicle spawned:', vehicleId, 'Net ID:', netId, 'Plate:', playerVehicle.props.plate)
    return netId
end)