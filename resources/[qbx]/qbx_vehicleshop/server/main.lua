lib.versionCheck('Qbox-project/qbx_vehicleshop')
assert(lib.checkDependency('qbx_core', '1.17.2'), 'qbx_core v1.17.2 or higher is required')
assert(lib.checkDependency('qbx_vehicles', '1.4.1'), 'qbx_vehicles v1.4.1 or higher is required')

local config = require 'config.server'
local sharedConfig = require 'config.shared'
local financeStorage = require 'server.storage'
COREVEHICLES = exports.qbx_core:GetVehiclesByName()
local saleTimeout = {}
local testDrives = {}

lib.callback.register('qbx_vehicleshop:server:canCarryKey', function(source)
    return exports.ox_inventory:CanCarryItem(source, 'vehicle_key', 1)
end)

---@param data {toVehicle: string}
RegisterNetEvent('qbx_vehicleshop:server:swapVehicle', function(data)
    if not CheckVehicleList(data.toVehicle) then return end
    TriggerClientEvent('qbx_vehicleshop:client:swapVehicle', -1, data)
end)

---@param vehicle string
RegisterNetEvent('qbx_vehicleshop:server:testDrive', function(vehicle)
    if not sharedConfig.enableTestDrive then return end
    local src = source

    if Player(src).state.isInTestDrive then
        return exports.qbx_core:Notify(src, locale('error.testdrive_alreadyin'), 'error')
    end

    local shopId = GetShopZone(src)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.qbx_core:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    local testDrive = shop.testDrive
    local plate = 'TEST'..lib.string.random('1111')

    local netId = SpawnVehicle(src, {
        modelName = vehicle,
        coords = coords,
        plate = plate
    })

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        exports['khaizerdn-vehiclekeys']:GiveKey(src, vehicle, true) -- Give temporary key
    end

    testDrives[src] = {
        netId = netId,
        endBehavior = testDrive.endBehavior,
        returnLocation = shop.returnLocation
    }

    Player(src).state:set('isInTestDrive', testDrive.limit, true)
    SetTimeout(testDrive.limit * 60000, function()
        Player(src).state:set('isInTestDrive', nil, true)
    end)
end)

---@param vehicle string
---@param playerId string|number
RegisterNetEvent('qbx_vehicleshop:server:customTestDrive', function(vehicle, playerId)
    local src = source
    local target = tonumber(playerId) --[[@as number]]

    if not exports.qbx_core:GetPlayer(target) then
        exports.qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
        return
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target))) < 3 then
        TriggerClientEvent('qbx_vehicleshop:client:testDrive', target, { vehicle = vehicle })
    else
        exports.qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end
end)

AddStateBagChangeHandler('isInTestDrive', nil, function(bagName, _, value)
    if value then return end

    local plySrc = GetPlayerFromStateBagName(bagName)
    if not plySrc then return end
    local testDrive = testDrives[plySrc]
    if not testDrive then return end
    local netId = testDrive.netId
    local endBehavior = testDrive.endBehavior
    if not netId or endBehavior == 'none' then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if endBehavior == 'return' then
        local coords = testDrive.returnLocation
        local plyPed = GetPlayerPed(plySrc)
        if #(GetEntityCoords(plyPed) - coords) > 10 then -- don't teleport if they are standing near the spot
            SetEntityCoords(plyPed, coords.x, coords.y, coords.z, false, false, false, false)
        end
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    elseif endBehavior == 'destroy' then
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
    testDrives[plySrc] = nil

    -- Remove temporary key
    local rawPlate = GetVehicleNumberPlateText(vehicle)
    local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate
    local items = exports.ox_inventory:Search(plySrc, 'slots', 'vehicle_key', { plate = plate })

    for _, item in pairs(items) do
        if item.metadata and item.metadata.temporary then
            exports.ox_inventory:RemoveItem(plySrc, 'vehicle_key', 1, item.metadata)
            break -- assume only one temp key per plate
        end
    end
end)

AddEventHandler('onResourceStop', function (resourceName)
    if cache.resource ~= resourceName then return end

    for player, _ in pairs(testDrives) do
        Player(player).state:set('isInTestDrive', nil, true)
    end
end)

---@param vehicle string
RegisterNetEvent('qbx_vehicleshop:server:buyShowroomVehicle', function(vehicle)
    local src = source

    local shopId = GetShopZone(src)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.qbx_core:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    local player = exports.qbx_core:GetPlayer(src)
    local vehiclePrice = COREVEHICLES[vehicle].price
    if not RemoveMoney(src, vehiclePrice, 'vehicle-bought-in-showroom') then
        return
    end

    local vehicleId = exports.qbx_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = player.PlayerData.citizenid,
    })

    exports.qbx_core:Notify(src, locale('success.purchased'), 'success')

    local netId = SpawnVehicle(src, {
        coords = coords,
        vehicleId = vehicleId
    })
end)

---@param src number
---@param target table
---@param price number
---@param downPayment number
---@return boolean success
function SellShowroomVehicleTransact(src, target, price, downPayment)
    local player = exports.qbx_core:GetPlayer(src)

    if not RemoveMoney(target.PlayerData.source, downPayment, 'vehicle-bought-in-showroom') then
        exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    local commission = lib.math.round(price * config.commissionRate)
    config.addPlayerFunds(player, 'bank', commission, 'vehicle-commission')
    exports.qbx_core:Notify(src, locale('success.earned_commission', lib.math.groupdigits(commission)), 'success')

    config.addSocietyFunds(player.PlayerData.job.name, price)
    exports.qbx_core:Notify(target.PlayerData.source, locale('success.purchased'), 'success')

    return true
end

---@param vehicle string
---@param playerId string|number
RegisterNetEvent('qbx_vehicleshop:server:sellShowroomVehicle', function(vehicle, playerId)
    local src = source
    local target = exports.qbx_core:GetPlayer(tonumber(playerId))

    if not target then
        return exports.qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return exports.qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end

    local shopId = GetShopZone(target.PlayerData.source)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.qbx_core:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    local vehiclePrice = COREVEHICLES[vehicle].price
    local cid = target.PlayerData.citizenid

    if not SellShowroomVehicleTransact(src, target, vehiclePrice, vehiclePrice) then return end

    local vehicleId = exports.qbx_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = cid,
    })

    local netId = SpawnVehicle(playerId, {
        coords = coords,
        vehicleId = vehicleId
    })

    -- Give key to the buyer
    local vehicleEntity = NetworkGetEntityFromNetworkId(netId)
    if vehicleEntity and DoesEntityExist(vehicleEntity) then
        exports['khaizerdn-vehiclekeys']:GiveKey(playerId, vehicleEntity)
    end
end)

-- Transfer vehicle to player in passenger seat
lib.addCommand('transfervehicle', {
    help = locale('general.command_transfervehicle'),
    params = {
        {
            name = 'id',
            type = 'playerId',
            help = locale('general.command_transfervehicle_help')
        },
        {
            name = 'amount',
            type = 'number',
            help = locale('general.command_transfervehicle_amount'),
            optional = true
        }
    }
}, function(source, args)
    local buyerId = args.id
    local sellAmount = args.amount or 0

    if source == buyerId then
        return exports.qbx_core:Notify(source, locale('error.selftransfer'), 'error')
    end
    if saleTimeout[source] then
        return exports.qbx_core:Notify(source, locale('error.sale_timeout'), 'error')
    end
    if buyerId == 0 then
        return exports.qbx_core:Notify(source, locale('error.Invalid_ID'), 'error')
    end

    local ped = GetPlayerPed(source)
    local targetPed = GetPlayerPed(buyerId)
    if targetPed == 0 then
        return exports.qbx_core:Notify(source, locale('error.buyerinfo'), 'error')
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        return exports.qbx_core:Notify(source, locale('error.notinveh'), 'error')
    end

    local vehicleId = Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    if not vehicleId then
        return exports.qbx_core:Notify(source, locale('error.notowned'), 'error')
    end

    local player = exports.qbx_core:GetPlayer(source)
    local target = exports.qbx_core:GetPlayer(buyerId)
    local row = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)
    local isFinanced = sharedConfig.finance.enable and financeStorage.fetchIsFinanced(vehicleId)

    if not row then return end

    if config.finance.preventSelling and isFinanced then
        return exports.qbx_core:Notify(source, locale('error.financed'), 'error')
    end

    if row.citizenid ~= player.PlayerData.citizenid then
        return exports.qbx_core:Notify(source, locale('error.notown'), 'error')
    end

    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 5.0 then
        return exports.qbx_core:Notify(source, locale('error.playertoofar'), 'error')
    end

    local canCarry = exports.ox_inventory:CanCarryItem(buyerId, 'vehicle_key', 1)
    if not canCarry then
        return exports.qbx_core:Notify(source, 'Buyer\'s inventory is full!', 'error')
    end

    saleTimeout[source] = true

    SetTimeout(config.saleTimeout, function()
        saleTimeout[source] = false
    end)

    if isFinanced then
        local financeData = financeStorage.fetchFinancedVehicleEntityById(vehicleId)
        local confirmFinance = lib.callback.await('qbx_vehicleshop:client:confirmFinance', buyerId, financeData)
        if not confirmFinance then
            return exports.qbx_core:Notify(source, locale('error.buyerdeclined'), 'error')
        end
    end

    lib.callback('qbx_vehicleshop:client:confirmTrade', buyerId, function(approved)
        if not approved then
            exports.qbx_core:Notify(source, locale('error.buyerdeclined'), 'error')
            return
        end

        if sellAmount > 0 then
            local currencyType = FindChargeableCurrencyType(sellAmount, target.PlayerData.money.cash, target.PlayerData.money.bank)

            if not currencyType then
                return exports.qbx_core:Notify(source, locale('error.buyertoopoor'), 'error')
            end

            config.addPlayerFunds(player, currencyType, sellAmount, 'vehicle-sold-to-player')
            config.removePlayerFunds(target, currencyType, sellAmount, 'vehicle-bought-from-player')
        end

        exports.qbx_vehicles:SetPlayerVehicleOwner(row.id, targetcid)
        config.giveKeys(buyerId, row.plate, vehicle)

        local sellerMessage = sellAmount > 0 and locale('success.soldfor') .. lib.math.groupdigits(sellAmount) or locale('success.gifted')
        local buyerMessage = sellAmount > 0 and locale('success.boughtfor') .. lib.math.groupdigits(sellAmount) or locale('success.received_gift')

        exports.qbx_core:Notify(source, sellerMessage, 'success')
        exports.qbx_core:Notify(buyerId, buyerMessage, 'success')
        if isFinanced then
            SetHasFinanced(buyerId, true)
        end
    end, GetEntityModel(vehicle), sellAmount)
end)

---@param source number
---@return PlayerVehicle[]?
lib.callback.register('qbx_vehicleshop:server:getOwnedVehicles', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { citizenid })
    if not vehicles or #vehicles == 0 then return end

    local result = {}
    for _, v in pairs(vehicles) do
        local props = json.decode(v.mods or '{}')
        result[#result + 1] = {
            modelName = v.vehicle,
            props = props
        }
    end

    return result
end)

RegisterServerEvent('qbx_vehicleshop:server:replaceKey', function(props, price)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    if not props or not props.plate or not props.model then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid vehicle data.', 'error')
        return
    end

    if Player.Functions.RemoveMoney('cash', price, 'vehicle-key-replace') then
        local rawPlate = props.plate
        local plate = string.upper(string.gsub(rawPlate, "%s+", "")) -- Normalize plate
        local model = props.model

        local metadata = {
            plate = plate,
            model = model,
            description = rawPlate,
            temporary = false
        }

        local success = exports.ox_inventory:AddItem(src, 'vehicle_key', 1, metadata)
        if success then
            TriggerClientEvent('QBCore:Notify', src, ('You received a key for %s (%s)'):format(rawPlate), 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to add key item.', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash', 'error')
    end
end)
