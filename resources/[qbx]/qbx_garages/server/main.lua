assert(lib.checkDependency('qbx_core', '1.19.0', true))
assert(lib.checkDependency('qbx_vehicles', '1.3.1', true))
lib.versionCheck('Qbox-project/qbx_garages')

---@class ErrorResult
---@field code string
---@field message string

---@class PlayerVehicle
---@field id number
---@field citizenid? string
---@field modelName string
---@field garage string
---@field state VehicleState
---@field depotPrice integer
---@field props table ox_lib properties table
---@field parked_position? table JSON-encoded vec4 (x, y, z, w)

Config = require 'config.server'
VEHICLES = exports.qbx_core:GetVehiclesByName()
Storage = require 'server.storage'
---@type table<string, GarageConfig>
Garages = Config.garages

lib.callback.register('qbx_garages:server:getGarages', function()
    return Garages
end)

---Returns garages for use server side.
local function getGarages()
    return Garages
end
exports('GetGarages', getGarages)

---@param name string
---@param config GarageConfig
local function registerGarage(name, config)
    Garages[name] = config
    TriggerClientEvent('qbx_garages:client:garageRegistered', -1, name, config)
    TriggerEvent('qbx_garages:server:garageRegistered', name, config)
end

exports('RegisterGarage', registerGarage)

---Sets the vehicle's garage. It is the caller's responsibility to make sure the vehicle is not currently spawned in the world, or else this may have no effect.
---@param vehicleId integer
---@param garageName string
---@return boolean success, ErrorResult?
local function setVehicleGarage(vehicleId, garageName)
    local garage = Garages[garageName]
    if not garage then
        return false, {
            code = 'not_found',
            message = string.format('garage name %s not found. Did you forget to register it?', garageName)
        }
    end

    local state = garage.type == GarageType.DEPOT and VehicleState.IMPOUNDED or VehicleState.GARAGED
    local numRowsAffected = Storage.setVehicleGarage(vehicleId, garageName, state)
    if numRowsAffected == 0 then
        return false, {
            code = 'no_rows_changed',
            message = string.format('no rows were changed for vehicleId=%s', vehicleId)
        }
    end
    return true
end

exports('SetVehicleGarage', setVehicleGarage)

---Sets the vehicle's price for retrieval at a depot. Only affects vehicles that are OUT or IMPOUNDED.
---@param vehicleId integer
---@param depotPrice integer
---@return boolean success, ErrorResult?
local function setVehicleDepotPrice(vehicleId, depotPrice)
    local numRowsAffected = Storage.setVehicleDepotPrice(vehicleId, depotPrice)
    if numRowsAffected == 0 then
        return false, {
            code = 'no_rows_changed',
            message = string.format('no rows were changed for vehicleId=%s', vehicleId)
        }
    end
    return true
end

exports('SetVehicleDepotPrice', setVehicleDepotPrice)

function FindPlateOnServer(plate)
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        if plate == GetVehicleNumberPlateText(vehicles[i]) then
            return true
        end
    end
end

---@param garage string
---@return GarageType?
function GetGarageType(garage)
    return Garages[garage]?.type
end

---@param source number
---@param garageName string
---@return PlayerVehiclesFilters
function GetPlayerVehicleFilter(source, garageName)
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    local filter = {}
    filter.citizenid = not garage.shared and player.PlayerData.citizenid or nil
    filter.states = garage.states or VehicleState.GARAGED
    filter.garage = not garage.skipGarageCheck and garageName or nil
    return filter
end

local function getCanAccessGarage(player, garage)
    if garage.groups and not exports.qbx_core:HasPrimaryGroup(player.PlayerData.source, garage.groups) then
        return false
    end
    if garage.canAccess ~= nil and not garage.canAccess(player.PlayerData.source) then
        return false
    end
    return true
end

---@param playerVehicle PlayerVehicle
---@return VehicleType
local function getVehicleType(playerVehicle)
    if not playerVehicle or not playerVehicle.modelName or not VEHICLES[playerVehicle.modelName] then
        return VehicleType.CAR -- Default to CAR if model is invalid or unknown
    end
    local category = VEHICLES[playerVehicle.modelName].category
    if category == 'helicopters' or category == 'planes' then
        return VehicleType.AIR
    elseif category == 'boats' then
        return VehicleType.SEA
    else
        return VehicleType.CAR
    end
end

---@param source number
---@param garageName string
---@return PlayerVehicle[]?
lib.callback.register('qbx_garages:server:getGarageVehicles', function(source, garageName)
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    if not getCanAccessGarage(player, garage) then return end
    local filter = GetPlayerVehicleFilter(source, garageName)
    local playerVehicles = exports.qbx_vehicles:GetPlayerVehicles(filter)
    local toSend = {}
    if not playerVehicles[1] then return end
    for _, vehicle in pairs(playerVehicles) do
        if not FindPlateOnServer(vehicle.props.plate) then
            local vehicleType = Garages[garageName].vehicleType
            if vehicleType == getVehicleType(vehicle) then
                toSend[#toSend + 1] = vehicle
            end
        end
    end
    return toSend
end)

---@param source number
---@param vehicleId string
---@param garageName string
---@param netId number
---@return boolean
local function isParkable(source, vehicleId, garageName, netId)
    local garageType = GetGarageType(garageName)
    --- DEPOTS are only for retrieving, not storing
    if garageType == GarageType.DEPOT then return false end
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    if not getCanAccessGarage(player, garage) then
        return false
    end
    ---@type PlayerVehicle
    local playerVehicle = vehicleId and exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    if garage.allowUnowned then
        -- Allow any vehicle (owned or unowned) of the correct type
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        local modelHash = GetEntityModel(vehicle)
        local modelName
        if playerVehicle then
            modelName = playerVehicle.modelName
        else
            -- Find model name by hash in VEHICLES table
            for name, vehicleData in pairs(VEHICLES) do
                if vehicleData.hash == modelHash then
                    modelName = name
                    break
                end
            end
        end
        if not modelName then
            return false -- Invalid or unknown model
        end
        return getVehicleType({ modelName = modelName }) == garage.vehicleType
    end
    if not playerVehicle then
        return false
    end
    if getVehicleType(playerVehicle) ~= garage.vehicleType then
        return false
    end
    if not garage.shared then
        if playerVehicle.citizenid ~= player.PlayerData.citizenid then
            return false
        end
    end
    return true
end

-- Add this function to count vehicles in a garage
---@param garageName string
---@return integer vehicleCount
local function getGarageVehicleCount(garageName)
    local query = 'SELECT COUNT(*) as count FROM player_vehicles WHERE garage = ? AND state IN (?, ?)'
    local result = MySQL.query.await(query, {garageName, VehicleState.GARAGED, VehicleState.IMPOUNDED})
    return result[1].count or 0
end

-- Modify the isParkable callback
lib.callback.register('qbx_garages:server:isParkable', function(source, garage, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    local garageType = GetGarageType(garage)
    if garageType == GarageType.DEPOT then return false, 'depot' end

    local player = exports.qbx_core:GetPlayer(source)
    local garageConfig = Garages[garage]
    if not getCanAccessGarage(player, garageConfig) then
        return false, 'no_access'
    end

    if garageConfig.maxVehicles then
        local vehicleCount = getGarageVehicleCount(garage)
        if vehicleCount >= garageConfig.maxVehicles then
            return false, 'garage_full'
        end
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local modelHash = GetEntityModel(vehicle)
    local modelName
    for name, vehicleData in pairs(VEHICLES) do
        if vehicleData.hash == modelHash then
            modelName = name
            break
        end
    end
    if not modelName then
        return false, 'invalid_model'
    end
    local vehicleType = getVehicleType({ modelName = modelName })
    if vehicleType ~= garageConfig.vehicleType then
        return false, 'wrong_type'
    end

    if garageConfig.allowUnowned then
        return true, nil
    end

    local playerVehicle = vehicleId and exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    if not playerVehicle then
        return false, 'not_owned'
    end
    if getVehicleType(playerVehicle) ~= garageConfig.vehicleType then
        return false, 'wrong_type'
    end
    if not garageConfig.shared then
        if playerVehicle.citizenid ~= player.PlayerData.citizenid then
            return false, 'not_owned'
        end
    end
    return true, nil
end)

---@param source number
---@param netId number
---@param props table ox_lib vehicle props https://github.com/overextended/ox_lib/blob/master/resource/vehicleProperties/client.lua#L3
---@param garage string
---@param parkedPosition table JSON-encoded vec4
lib.callback.register('qbx_garages:server:parkVehicle', function(source, netId, props, garage, parkedPosition)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    local garageConfig = Garages[garage]
    if not garageConfig then
        exports.qbx_core:Notify(source, 'Garage not found', 'error')
        return false
    end

    local isParkableResult = isParkable(source, vehicleId, garage, netId)
    if not isParkableResult then
        exports.qbx_core:Notify(source, locale('error.not_correct_type'), 'error')
        return false
    end

    if garageConfig.allowUnowned and not vehicleId then
        -- Create a new vehicle entry for unowned vehicles
        local modelHash = GetEntityModel(vehicle)
        local modelName
        for name, vehicleData in pairs(VEHICLES) do
            if vehicleData.hash == modelHash then
                modelName = name
                break
            end
        end
        if not modelName then
            exports.qbx_core:Notify(source, locale('error.not_correct_type'), 'error')
            return false
        end

        local newVehicleId = exports.qbx_vehicles:CreatePlayerVehicle({
            model = modelName,
            citizenid = nil,
            garage = garage,
            props = props,
            parked_position = parkedPosition
        })
        if not newVehicleId then
            exports.qbx_core:Notify(source, 'Failed to save vehicle', 'error')
            return false
        end
        Entity(vehicle).state:set('vehicleid', newVehicleId, true)
        Entity(vehicle).state:set('garage', garage, true)
    else
        -- Update existing vehicle
        if not isParkable(source, vehicleId, garage, netId) then
            exports.qbx_core:Notify(source, locale('error.not_owned'), 'error')
            return false
        end
        exports.qbx_vehicles:SaveVehicle(vehicle, {
            garage = garage,
            state = VehicleState.GARAGED,
            props = props,
            parked_position = parkedPosition
        })
        Entity(vehicle).state:set('garage', garage, true)
    end
    exports.qbx_core:Notify(source, locale('success.vehicle_parked'), 'primary')
    return true
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    Wait(100)
end)

RegisterNetEvent('qbx_garages:server:setVehicleOut', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or GetEntityType(vehicle) ~= 2 then
        lib.print.debug('Invalid vehicle or not a vehicle for Net ID:', netId)
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(plate)
    if not vehicleId then
        lib.print.debug('No vehicleId found for Net ID:', netId, 'Plate:', plate)
        return
    end

    local playerVehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    if not playerVehicle then
        lib.print.debug('No player vehicle found for vehicleId:', vehicleId, 'Net ID:', netId, 'Plate:', plate)
        return
    end

    -- Update vehicle state to OUT, clear garage and parked_position
    lib.print.debug('Setting vehicle to OUT:', vehicleId, 'Net ID:', netId, 'Plate:', plate, 'Current State:', playerVehicle.state)
    local success, errorResult = exports.qbx_vehicles:SaveVehicle(vehicle, {
        garage = nil,
        state = VehicleState.OUT,
        parked_position = nil -- Clear parked_position
    })
    if not success then
        lib.print.debug('Failed to update vehicle state to OUT:', vehicleId, 'Error:', errorResult)
        return
    end
    Entity(vehicle).state:set('garage', nil, true)
    Entity(vehicle).state:set('vehicleid', vehicleId, true) -- Ensure vehicleid is persisted
    lib.print.debug('Vehicle state updated to OUT for vehicleId:', vehicleId, 'Net ID:', netId, 'Plate:', plate)
end)

---@param vehicleId string
---@return boolean? success true if successfully paid
lib.callback.register('qbx_garages:server:payDepotPrice', function(source, vehicleId)
    local player = exports.qbx_core:GetPlayer(source)
    local cashBalance = player.PlayerData.money.cash
    local bankBalance = player.PlayerData.money.bank

    local vehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    local depotPrice = vehicle.depotPrice
    if not depotPrice or depotPrice == 0 then return true end
    if cashBalance >= depotPrice then
        player.Functions.RemoveMoney('cash', depotPrice, 'paid-depot')
        return true
    elseif bankBalance >= depotPrice then
        player.Functions.RemoveMoney('bank', depotPrice, 'paid-depot')
        return true
    end
end)

lib.callback.register('qbx_garages:server:getGaragedVehicles', function(source)
    local filter = { states = VehicleState.GARAGED }
    local playerVehicles = exports.qbx_vehicles:GetPlayerVehicles(filter)
    return playerVehicles
end)

RegisterNetEvent('qbx_garages:server:toggleVehicleLock', function(netId, lock)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or GetEntityType(vehicle) ~= 2 then return end
    local newState = lock and 2 or 1 -- 2 = locked, 1 = unlocked
    Entity(vehicle).state:set('doorslockstate', newState, true)
    lib.print.debug('Toggled lock state for vehicle, Net ID:', netId, 'State:', newState)
end)