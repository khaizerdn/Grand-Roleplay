lib.locale()

local peds = require "server.peds"
require "server.version"

--- Gets the closest store to the provided coords
---@param position vector3
---@return number | nil
local function getClosestStore(position)
    local closest, closestDist = nil, nil

    for i = 1, #Config.Locations do
        local clerkPos = Config.Locations[i].ped
        local dist = #(vector3(clerkPos.x, clerkPos.y, clerkPos.z) - position)

        if not closestDist or dist < closestDist then
            closest = i
            closestDist = dist
        end
    end

    return closest
end

--- Generates the code for a safe
local function generateSafeCode()
    local number = tostring(math.random(0, 9999))
    return string.format("%04d", number) -- Format string by placing 0 in front of 3 digit numbers
end

local function updateStore(storeIndex, key, value)
    if not storeIndex or type(storeIndex) ~= "number" then return end
    if not key or type(key) ~= "string" then return end
    if not value then return end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]

    for k, v in pairs(storeData) do
        if k == key then
            storeData[k] = value
        end
    end

    GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)] = storeData
end

--- Resets all the robbery states for a specific store back to default value
---@param index number
local function finishRobbery(index)
    if not index or type(index) ~= "number" then return end
    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
    if not storeData then return end

    local safeNetworkId = storeData.safeNet
    updateStore(index, "active", false)
    updateStore(index, "robbedTill", false)
    updateStore(index, "hackedNetwork", false)
    updateStore(index, "openedSafe", false)
    updateStore(index, "safeNet", -1)
    updateStore(index, "cooldown", os.time() + Config.StoreCooldown)

    TriggerClientEvent("ff_shoprobbery:client:disableNetwork", -1, index)

    -- Delete ped and safe
    local pedNet = peds.getClosest(Config.Locations[index].ped)
    if pedNet then
        local pedEntity = NetworkGetEntityFromNetworkId(pedNet)
        if pedEntity and DoesEntityExist(pedEntity) then
            DeleteEntity(pedEntity)
        end
    end
    if safeNetworkId and safeNetworkId > 0 then
        local safeEntity = NetworkGetEntityFromNetworkId(safeNetworkId)
        if safeEntity and DoesEntityExist(safeEntity) then
            DeleteEntity(safeEntity)
        end
    end

    -- Reset store after cooldown by respawning ped and safe
    SetTimeout(Config.StoreCooldown * 1000, function()
        if GlobalState[string.format("ff_shoprobbery:store:%s", index)].cooldown ~= -1 then
            updateStore(index, "cooldown", -1)
            peds.create(Config.Locations[index].ped, index) -- Respawn ped
            local success, netId = lib.callback.await("ff_shoprobbery:createSafe", false, Config.Locations[index].safe)
            if success then
                updateStore(index, "safeNet", netId)
            end
        end
    end)
end

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    peds.deleteAll()
end)

---@param tillCoords vector3
---@param tillRotation vector3
RegisterNetEvent("ff_shoprobbery:server:startedRobbery", function(tillCoords, tillRotation)
    if not tillCoords or not tillRotation then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(tillCoords)
    if not closestStore then
        return Notify(src, "Store not found", "error")
    end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)]
    if storeData.active then
        return Notify(src, "This store is already being robbed", "error")
    end

    if storeData.cooldown ~= -1 then
        return Notify(src, "This store is on cooldown", "error")
    end

    local activePolice = GetPoliceCount()
    if activePolice < Config.RequiredPolice then
        return Notify(src, string.format(locale("error.not_enough_police"), Config.RequiredPolice), "error")
    end

    local netId, distance = peds.getClosest(tillCoords)
    if not netId or not distance then return end
    if distance >= 3.0 then return end

    updateStore(closestStore, "active", true)
    TriggerClientEvent("ff_shoprobbery:client:robTill", src, netId, tillCoords, tillRotation)
    SendLog(src, GetPlayerName(src), locale("logs.started.title"), string.format(locale("logs.started.description"), closestStore), Colours.FiveForgeBlue)
end)

---@param tillCoords vector3
RegisterNetEvent("ff_shoprobbery:server:removeTill", function(tillCoords)
    if not tillCoords then return end
    TriggerClientEvent("ff_shoprobbery:client:removeTill", -1, tillCoords)
end)

---@param tillCoords vector3
RegisterNetEvent("ff_shoprobbery:server:restoreTill", function(tillCoords)
    if not tillCoords then return end
    TriggerClientEvent("ff_shoprobbery:client:restoreTill", -1, tillCoords)
end)

---@param pickupCoords vector3
---@param pickupRotation vector3
RegisterNetEvent("ff_shoprobbery:server:cashDropped", function(pickupCoords, pickupRotation)
    if not pickupCoords then return end
    if not pickupRotation then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(pickupCoords)
    if not closestStore or not GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].active then return end

    local success, netId = lib.callback.await("ff_shoprobbery:createSafe", src, Config.Locations[closestStore].safe)
    if not success or (not netId or netId <= 0) then return end

    updateStore(closestStore, "safeNet", netId)
    updateStore(closestStore, "robbedTill", true)
    TriggerClientEvent("ff_shoprobbery:client:cashDropped", -1, pickupCoords, pickupRotation)
    SendLog(src, GetPlayerName(src), locale("logs.loot_dropped.title"), string.format(locale("logs.loot_dropped.description"), closestStore), Colours.FiveForgeBlue)
end)

---@param pickupCoords vector3
RegisterNetEvent("ff_shoprobbery:server:cashCollected", function(pickupCoords)
    if not pickupCoords then return end
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    local closestStore = getClosestStore(pickupCoords)
    if not closestStore or not GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].active then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    if #(pedCoords - pickupCoords) > 1.5 then return end
    TriggerClientEvent("ff_shoprobbery:client:cashCollected", -1, pickupCoords)
    local value = math.random(Config.TillValue.min, Config.TillValue.max)
    if Config.UseBlackMoney then
        GiveItem(src, "black_money", value)
    else
        GiveMoney(src, value, "collected money from till")
    end
    SendLog(src, GetPlayerName(src), locale("logs.loot_collected.title"), string.format(locale("logs.loot_collected.description"), value, closestStore), Colours.FiveForgeBlue)
end)

---@param source number
---@param storeIndex number
---@return boolean, string?
lib.callback.register('ff_shoprobbery:getSafeCode', function(source, storeIndex)
    if not storeIndex or type(storeIndex) ~= "number" then return false end

    local src = source
    local player = GetPlayer(src)
    if not player then return false end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]
    if not storeData or not storeData.active then return false end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    local storeConfig = Config.Locations[storeIndex]
    if not storeConfig or #(pedCoords - storeConfig.network.coords) > 2.0 then return false end

    updateStore(storeIndex, "hackedNetwork", true)
    SendLog(src, GetPlayerName(src), locale("logs.hacked_network.title"), string.format(locale("logs.hacked_network.description"), storeIndex), Colours.FiveForgeBlue)
    return true, storeData.safeCode
end)

---@param source number
---@param storeIndex number
---@param enteredCode string
---@return boolean
lib.callback.register('ff_shoprobbery:openSafe', function(source, storeIndex, enteredCode)
    if not storeIndex or type(storeIndex) ~= "number" then return false end
    if not enteredCode or type(enteredCode) ~= "string" then return false end

    local src = source
    local player = GetPlayer(src)
    if not player then return false end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]
    if not storeData or not storeData.active then return false end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    local storeConfig = Config.Locations[storeIndex]
    if not storeConfig or #(pedCoords - vector3(storeConfig.safe.x, storeConfig.safe.y, storeConfig.safe.z)) > 2.0 then return false end

    if storeData.safeCode ~= enteredCode then return false end
    updateStore(storeIndex, "openedSafe", true)
    SendLog(src, GetPlayerName(src), locale("logs.opened_safe.title"), string.format(locale("logs.opened_safe.description"), storeData.safeCode, storeIndex), Colours.FiveForgeBlue)
    return true
end)

---@param storeIndex number
---@param safeNet number
RegisterNetEvent("ff_shoprobbery:server:lootedSafe", function(storeIndex, safeNet)
    if not storeIndex or type(storeIndex) ~= "number" then return end
    if not safeNet or type(safeNet) ~= "number" then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]
    if not storeData or not storeData.active then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    local storeConfig = Config.Locations[storeIndex]
    if not storeConfig or #(pedCoords - vector3(storeConfig.safe.x, storeConfig.safe.y, storeConfig.safe.z)) > 2.0 then return end

    for _, itemData in pairs(Config.SafeItems) do
        if not itemData.chance or math.random(100) >= itemData.chance then
            GiveItem(src, itemData.item, math.random(itemData.amount.min, itemData.amount.max))
        end
    end

    finishRobbery(storeIndex)
    SendLog(src, GetPlayerName(src), locale("logs.looted_safe.title"), string.format(locale("logs.looted_safe.description"), storeIndex), Colours.FiveForgeBlue)
end)

-- Process store initial setup (store global states and till clerks)
CreateThread(function()
    for i = 1, #Config.Locations do
        GlobalState[string.format("ff_shoprobbery:store:%s", i)] = {
            active = false,
            robbedTill = false,
            cooldown = -1,
            hackedNetwork = false,
            safeCode = generateSafeCode(),
            openedSafe = false,
            safeNet = -1
        }
        peds.create(Config.Locations[i].ped, i)  -- Pass storeIndex
    end
end)

lib.addCommand('resetstore', {
    help = 'This will remove a specific store cooldown.',
    params = {
        {
            name = "storeId",
            type = "number",
            help = "The ID of the store to reset"
        }
    },
}, function(source, args)
    if not CanReset(source) then return end
    local src = source

    local storeIndex = tonumber(args.storeId)
    if not storeIndex then return end

    if GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)].cooldown ~= -1 then
        updateStore(storeIndex, "cooldown", -1)
        
        local safeNet = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)].lastSafe
        if safeNet then
            local entity = NetworkGetEntityFromNetworkId(safeNet)
            if entity and DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
            updateStore(storeIndex, "lastSafe", -1)
        end
        
        SendLog(src, GetPlayerName(src), locale("logs.store_cooldown.title"), string.format(locale("logs.store_cooldown.description"), storeIndex), Colours.FiveForgeBlue)
    else
        Notify(src, "This store is not on cooldown", "error")
    end
end)

-- Reset all stores
lib.addCommand('resetstores', {
    help = 'This will reset all store cooldowns and respawn peds and safes.',
    params = {},
}, function(source, args)
    if not CanReset(source) then return end
    local src = source

    for i = 1, #Config.Locations do
        local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", i)]
        if storeData.cooldown ~= -1 then
            local pedNet = peds.getClosest(Config.Locations[i].ped)
            if pedNet then
                local pedEntity = NetworkGetEntityFromNetworkId(pedNet)
                if pedEntity and DoesEntityExist(pedEntity) then
                    DeleteEntity(pedEntity)
                end
            end
            local safeNet = storeData.safeNet
            if safeNet and safeNet > 0 then
                local safeEntity = NetworkGetEntityFromNetworkId(safeNet)
                if safeEntity and DoesEntityExist(safeEntity) then
                    DeleteEntity(safeEntity)
                end
            end
            peds.create(Config.Locations[i].ped, i) -- Respawn ped
            local success, netId = lib.callback.await("ff_shoprobbery:createSafe", false, Config.Locations[i].safe)
            if success then
                updateStore(i, "safeNet", netId)
            end
        end
        GlobalState[string.format("ff_shoprobbery:store:%s", i)] = {
            active = false,
            robbedTill = false,
            cooldown = -1,
            hackedNetwork = false,
            safeCode = generateSafeCode(),
            openedSafe = false,
            safeNet = -1
        }
    end

    SendLog(src, GetPlayerName(src), locale("logs.global_cooldown.title"), "All stores reset", Colours.FiveForgeBlue)
end)

RegisterNetEvent("ff_shoprobbery:server:cancelRobbery", function(tillCoords)
    if not tillCoords then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(tillCoords)
    if not closestStore or not GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].active then return end

    finishRobbery(closestStore)
    TriggerClientEvent("ff_shoprobbery:client:cancelRobbery", -1)
    Notify(src, locale("error.robbery_cancelled_ped_dead"), "error")
    SendLog(src, GetPlayerName(src), locale("logs.cancelled.title"), string.format(locale("logs.cancelled.description"), closestStore), Colours.FiveForgeRed)
end)