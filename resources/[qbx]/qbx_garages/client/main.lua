local config = require 'config.client'
if not config.enableClient then return end
local VEHICLES = exports.qbx_core:GetVehiclesByName()

---@enum ProgressColor
local ProgressColor = {
    GREEN = 'green.5',
    YELLOW = 'yellow.5',
    RED = 'red.5'
}

---@param percent number
---@return string
local function getProgressColor(percent)
    if percent >= 75 then
        return ProgressColor.GREEN
    elseif percent > 25 then
        return ProgressColor.YELLOW
    else
        return ProgressColor.RED
    end
end

local VehicleCategory = {
    all = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
    car = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 22},
    air = {15, 16},
    sea = {14},
}

---@param category VehicleType
---@param vehicle number
---@return boolean
local function isOfType(category, vehicle)
    local classSet = {}

    for _, class in pairs(VehicleCategory[category]) do
        classSet[class] = true
    end

    return classSet[GetVehicleClass(vehicle)] == true
end

---@param vehicle number
local function kickOutPeds(vehicle)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
        end
    end
end

local spawnLock = false

---@param vehicleId number
---@param garageName string
---@param accessPoint integer
local function takeOutOfGarage(vehicleId, garageName, accessPoint)
    if spawnLock then
        exports.qbx_core:Notify(locale('error.spawn_in_progress'))
        return
    end
    spawnLock = true
    local success, result = pcall(function()
        if cache.vehicle then
            exports.qbx_core:Notify(locale('error.in_vehicle'))
            return
        end

        local netId = lib.callback.await('qbx_garages:server:spawnVehicle', false, vehicleId, garageName, accessPoint)
        if not netId then return end

        local veh = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then
                return NetToVeh(netId)
            end
        end)

        if veh == 0 then
            exports.qbx_core:Notify('Something went wrong spawning the vehicle', 'error')
            return
        end

        if config.engineOn then
            SetVehicleEngineOn(veh, true, true, false)
        end
    end)
    spawnLock = false
    assert(success, result)
end

---@param data {vehicle: PlayerVehicle, garageName: string, accessPoint: integer}
local function takeOutDepot(data)
    if data.vehicle.depotPrice ~= 0 then
        local success = lib.callback.await('qbx_garages:server:payDepotPrice', false, data.vehicle.id)
        if not success then
            exports.qbx_core:Notify(locale('error.not_enough'), 'error')
            return
        end
    end

    takeOutOfGarage(data.vehicle.id, data.garageName, data.accessPoint)
end

---@param vehicle PlayerVehicle
---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function displayVehicleInfo(vehicle, garageName, garageInfo, accessPoint)
    local engine = qbx.math.round(vehicle.props.engineHealth / 10)
    local body = qbx.math.round(vehicle.props.bodyHealth / 10)
    local engineColor = getProgressColor(engine)
    local bodyColor = getProgressColor(body)
    local fuelColor = getProgressColor(vehicle.props.fuelLevel)
    local vehicleLabel = ('%s %s'):format(VEHICLES[vehicle.modelName].brand, VEHICLES[vehicle.modelName].name)

    local options = {
        {
            title = locale('menu.information'),
            icon = 'circle-info',
            description = locale('menu.description', vehicleLabel, vehicle.props.plate, lib.math.groupdigits(vehicle.depotPrice)),
            readOnly = true,
        },
        {
            title = locale('menu.body'),
            icon = 'car-side',
            readOnly = true,
            progress = body,
            colorScheme = bodyColor,
        },
        {
            title = locale('menu.engine'),
            icon = 'oil-can',
            readOnly = true,
            progress = engine,
            colorScheme = engineColor,
        },
        {
            title = locale('menu.fuel'),
            icon = 'gas-pump',
            readOnly = true,
            progress = vehicle.props.fuelLevel,
            colorScheme = fuelColor,
        }
    }

    if vehicle.state == VehicleState.OUT then
        if garageInfo.type == GarageType.DEPOT then
            options[#options + 1] = {
                title = 'Take out',
                icon = 'fa-truck-ramp-box',
                description = ('$%s'):format(lib.math.groupdigits(vehicle.depotPrice)),
                arrow = true,
                onSelect = function()
                    takeOutDepot({
                        vehicle = vehicle,
                        garageName = garageName,
                        accessPoint = accessPoint,
                    })
                end,
            }
        else
            options[#options + 1] = {
                title = 'Your vehicle is already out...',
                icon = VehicleType.CAR,
                readOnly = true,
            }
        end
    elseif vehicle.state == VehicleState.IMPOUNDED then
        options[#options + 1] = {
            title = locale('menu.veh_impounded'),
            icon = 'building-shield',
            readOnly = true,
        }
    end

    lib.registerContext({
        id = 'vehicleList',
        title = garageInfo.label,
        menu = 'garageMenu',
        options = options,
    })

    lib.showContext('vehicleList')
end

---@param vehicle number
---@param garageName string
local function storeVehicle(vehicle, garageName)
    if GetVehicleNumberOfPassengers(vehicle) ~= 1 then
        local isParkable, errorCode = lib.callback.await('qbx_garages:server:isParkable', false, garageName, NetworkGetNetworkIdFromEntity(vehicle))
        if not isParkable then
            if errorCode == 'not_owned' then
                exports.qbx_core:Notify(locale('error.not_owned'), 'error')
            elseif errorCode == 'garage_full' then
                exports.qbx_core:Notify(locale('error.garage_full'), 'error')
            elseif errorCode == 'wrong_type' then
                exports.qbx_core:Notify(locale('error.not_correct_type'), 'error')
            elseif errorCode == 'no_access' then
                exports.qbx_core:Notify(locale('error.no_access'), 'error')
            else
                exports.qbx_core:Notify(locale('error.cannot_park'), 'error')
            end
            return
        end
        kickOutPeds(vehicle)
        Wait(1500)
        local props = lib.getVehicleProperties(vehicle)
        local position = GetEntityCoords(vehicle)
        local heading = GetEntityHeading(vehicle)
        local parkedPosition = { x = position.x, y = position.y, z = position.z, w = heading }
        lib.callback.await('qbx_garages:server:parkVehicle', false, NetworkGetNetworkIdFromEntity(vehicle), props, garageName, parkedPosition)
    else
        exports.qbx_core:Notify(locale('error.vehicle_occupied'), 'error')
    end
end

---@param garage GarageConfig
---@return boolean
local function checkCanAccess(garage)
    if garage.groups and not exports.qbx_core:HasPrimaryGroup(garage.groups, QBX.PlayerData) then
        exports.qbx_core:Notify(locale('error.no_access'), 'error')
        return false
    end
    if cache.vehicle and not isOfType(garage.vehicleType, cache.vehicle) then
        exports.qbx_core:Notify(locale('error.not_correct_type'), 'error')
        return false
    end
    return true
end

---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function openGarageMenu(garageName, garageInfo, accessPoint)
    ---@type PlayerVehicle[]?
    local vehicleEntities = lib.callback.await('qbx_garages:server:getGarageVehicles', false, garageName)

    if not vehicleEntities then
        exports.qbx_core:Notify(locale('error.no_vehicles'), 'error')
        return
    end

    table.sort(vehicleEntities, function(a, b)
        return a.modelName < b.modelName
    end)

    local options = {}
    for i = 1, #vehicleEntities do
        local vehicleEntity = vehicleEntities[i]
        local vehicleLabel = ('%s %s'):format(VEHICLES[vehicleEntity.modelName].brand, VEHICLES[vehicleEntity.modelName].name)

        options[#options + 1] = {
            title = vehicleLabel,
            description = vehicleEntity.props.plate,
            arrow = true,
            onSelect = function()
                displayVehicleInfo(vehicleEntity, garageName, garageInfo, accessPoint)
            end,
        }
    end

    lib.registerContext({
        id = 'garageMenu',
        title = garageInfo.label,
        options = options,
        onExit = function()
            if not cache.vehicle and garageInfo.type ~= GarageType.DEPOT then
                lib.showTextUI(locale('info.garage_e'), {
                    position = 'top-center',
                })
            elseif cache.vehicle and garageInfo.type ~= GarageType.DEPOT then
                lib.showTextUI(locale('info.park_e'), {
                    position = 'top-center',
                })
            elseif garageInfo.type == GarageType.DEPOT then
                lib.showTextUI(locale('info.impound_e'), {
                    position = 'top-center',
                })
            end
        end
    })

    lib.showContext('garageMenu')
end

---@param garageName string
---@param garage GarageConfig
---@param accessPoint AccessPoint
---@param accessPointIndex integer
local function createGarageZone(garageName, garage, accessPoint, accessPointIndex)
    CreateThread(function()
        local function calculatePolyzoneCenter(points)
            local xSum, ySum, zSum = 0, 0, 0
            for i = 1, #points do
                xSum = xSum + points[i].x
                ySum = ySum + points[i].y
                zSum = zSum + points[i].z
            end
            return vec3(xSum / #points, ySum / #points, zSum / #points)
        end

        local center = calculatePolyzoneCenter(accessPoint.points)
        local textUIShown = false

        lib.zones.poly({
            points = accessPoint.points,
            onEnter = function()
                if cache.vehicle and garage.type ~= GarageType.DEPOT then
                    lib.showTextUI(locale('info.park_e'), {
                        position = 'top-center',
                    })
                    textUIShown = true
                end
            end,
            onExit = function()
                lib.hideTextUI()
                textUIShown = false
                if cache.vehicle then
                    local vehicle = cache.vehicle
                    local netId = NetworkGetNetworkIdFromEntity(vehicle)
                    local vehicleState = Entity(vehicle).state
                    if vehicleState and vehicleState.vehicleid then
                        -- Add a slight delay to ensure server-client sync
                        Wait(2000)
                        lib.print.debug('Vehicle exiting garage zone:', garageName, 'Vehicle ID:', vehicleState.vehicleid, 'Net ID:', netId, 'Plate:', GetVehicleNumberPlateText(vehicle))
                        TriggerServerEvent('qbx_garages:server:setVehicleOut', netId)
                    else
                        lib.print.debug('No vehicle state or vehicleid for vehicle in garage:', garageName, 'Net ID:', netId, 'Plate:', GetVehicleNumberPlateText(vehicle))
                    end
                end
            end,
            inside = function()
                -- Check if player is in a vehicle or on foot and update text UI
                if cache.vehicle and garage.type ~= GarageType.DEPOT then
                    if not textUIShown then
                        lib.showTextUI(locale('info.park_e'), {
                            position = 'top-center',
                        })
                        textUIShown = true
                    end
                elseif not cache.vehicle and textUIShown then
                    lib.hideTextUI()
                    textUIShown = false
                end

                -- Handle [E] key press
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    if not checkCanAccess(garage) then return end
                    if cache.vehicle and garage.type ~= GarageType.DEPOT then
                        storeVehicle(cache.vehicle, garageName)
                    elseif not cache.vehicle then
                        exports.qbx_core:Notify('You are not in a vehicle.', 'error')
                        --openGarageMenu(garageName, garage, accessPointIndex)
                    end
                end
            end,
            debug = config.debugPoly,
        })
    end)
end
---@param garageName string
---@param garage GarageConfig
---@param accessPoint AccessPoint
local function createImpoundZone(garageName, garage, accessPoint)
    CreateThread(function()
        lib.zones.sphere({
            coords = accessPoint.interact,
            radius = 3.0,
            onEnter = function()
                lib.showTextUI(locale('info.impound_e'), {
                    position = 'top-center',
                })
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    if not checkCanAccess(garage) then return end
                    if not cache.vehicle then
                        openGarageMenu(garageName, garage, 1)
                    else
                        exports.qbx_core:Notify('You are in a vehicle', 'error')
                    end
                end
            end,
            debug = config.debugPoly,
        })
    end)
end

RegisterNetEvent('qbx_garages:client:setVehicleMissionEntity', function(netId)
    local veh = NetToVeh(netId)
    if DoesEntityExist(veh) then
        SetEntityAsMissionEntity(veh, true, true)
        lib.print.debug('Set vehicle as mission entity and placed on ground, Net ID:', netId)
    else
        lib.print.debug('Vehicle does not exist for Net ID:', netId)
    end
end)

---@param garageInfo GarageConfig
---@param accessPoint AccessPoint
local function createBlips(garageInfo, accessPoint)
    local blip = AddBlipForCoord(accessPoint.blip.coords.x, accessPoint.blip.coords.y, accessPoint.blip.coords.z)
    SetBlipSprite(blip, accessPoint.blip.sprite or 357)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.60)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, accessPoint.blip.color or 3)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(accessPoint.blip.name or garageInfo.label)
    EndTextCommandSetBlipName(blip)
end

local function createGarage(name, garage)
    local accessPoints = garage.accessPoints
    for i = 1, #accessPoints do
        local accessPoint = accessPoints[i]

        if accessPoint.blip then
            createBlips(garage, accessPoint)
        end

        if garage.type == GarageType.DEPOT then
            createImpoundZone(name, garage, accessPoint)
        else
            createGarageZone(name, garage, accessPoint, i)
        end
    end
end

local function createGarages()
    local garages = lib.callback.await('qbx_garages:server:getGarages')
    for name, garage in pairs(garages) do
        createGarage(name, garage)
    end
end

RegisterNetEvent('qbx_garages:client:garageRegistered', function(name, garage)
    createGarage(name, garage)
end)

CreateThread(function()
    createGarages()
end)