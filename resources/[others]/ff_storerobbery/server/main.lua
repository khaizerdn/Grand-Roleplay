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
---@param src number
---@param skipCooldown boolean
---@param setNonRobbable boolean
local function finishRobbery(index, src, skipCooldown, setNonRobbable)
    if not index or type(index) ~= "number" then return end
    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
    if not storeData then
        print(string.format("[DEBUG] No storeData for store %d, initializing", index))
        storeData = {
            active = false,
            robbedTill = false,
            cooldown = -1,
            nonRobbableUntil = -1,
            hackedNetwork = false,
            safeCode = generateSafeCode(),
            openedSafe = false,
            safeNet = -1
        }
    end

    local safeNetworkId = storeData.safeNet
    updateStore(index, "active", false)
    updateStore(index, "robbedTill", false)
    updateStore(index, "hackedNetwork", false)
    updateStore(index, "openedSafe", false)
    updateStore(index, "safeNet", -1)
    updateStore(index, "cooldown", skipCooldown and -1 or GetGameTimer() + Config.StoreCooldown * 1000)
    updateStore(index, "nonRobbableUntil", setNonRobbable and GetGameTimer() + Config.StoreCooldown * 1000 or -1)

    TriggerClientEvent("ff_shoprobbery:client:disableNetwork", -1, index)

    -- Handle ped
    local pedNet = peds.getClosest(Config.Locations[index].ped)
    if pedNet then
        local pedEntity = NetworkGetEntityFromNetworkId(pedNet)
        if pedEntity and DoesEntityExist(pedEntity) then
            local isDead = lib.callback.await('ff_shoprobbery:isPedDead', src, pedNet)
            if not isDead then
                print(string.format("[DEBUG] Deleting ped for store %d (netId: %d)", index, pedNet))
                DeleteEntity(pedEntity)
            else
                print(string.format("[DEBUG] Ped for store %d (netId: %d) is dead, not deleting", index, pedNet))
            end
        else
            print(string.format("[DEBUG] No valid ped entity found for store %d (netId: %d)", index, pedNet))
        end
    else
        print(string.format("[DEBUG] No ped found for store %d", index))
    end

    -- Delete safe
    if safeNetworkId and safeNetworkId > 0 then
        local safeEntity = NetworkGetEntityFromNetworkId(safeNetworkId)
        if safeEntity and DoesEntityExist(safeEntity) then
            print(string.format("[DEBUG] Deleting safe for store %d (netId: %d)", index, safeNetworkId))
            DeleteEntity(safeEntity)
        end
    end
    
    -- Reset store and spawn new ped/safe
    GlobalState[string.format("ff_shoprobbery:store:%s", index)] = {
        active = false,
        robbedTill = false,
        cooldown = skipCooldown and -1 or GetGameTimer() + Config.StoreCooldown * 1000,
        nonRobbableUntil = setNonRobbable and GetGameTimer() + Config.StoreCooldown * 1000 or -1,
        hackedNetwork = false,
        safeCode = generateSafeCode(),
        openedSafe = false,
        safeNet = -1
    }
    print(string.format("[DEBUG] Store %d reset: cooldown=%s, nonRobbableUntil=%s, new safe code generated", 
        index, skipCooldown and -1 or GetGameTimer() + Config.StoreCooldown * 1000, setNonRobbable and GetGameTimer() + Config.StoreCooldown * 1000 or -1))
    
    peds.create(Config.Locations[index].ped, index)
    local pedNet = peds.getClosest(Config.Locations[index].ped)
    print(string.format("[DEBUG] New ped spawned for store %d (netId: %s)", index, pedNet or "none"))
    
    local success, netId = lib.callback.await("ff_shoprobbery:createSafe", src, Config.Locations[index].safe)
    if success then
        updateStore(index, "safeNet", netId)
        print(string.format("[DEBUG] Safe created for store %d (netId: %d)", index, netId))
    else
        print(string.format("[DEBUG] Failed to create safe for store %d", index))
    end

    -- Clear nonRobbableUntil after cooldown
    if setNonRobbable then
        SetTimeout(Config.StoreCooldown * 1000, function()
            local storeKey = string.format("ff_shoprobbery:store:%s", index)
            if GlobalState[storeKey].nonRobbableUntil ~= -1 then
                updateStore(index, "nonRobbableUntil", -1)
                updateStore(index, "cooldown", -1)
                print(string.format("[DEBUG] Store %d non-robbable period ended", index))
            end
        end)
    end
end

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    peds.deleteAll()
end)

--- Initialize GlobalState for all stores
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for index, _ in ipairs(Config.Locations) do
        local storeKey = string.format("ff_shoprobbery:store:%s", index)
        if not GlobalState[storeKey] then
            GlobalState[storeKey] = {
                active = false,
                robbedTill = false,
                cooldown = -1,
                nonRobbableUntil = -1,
                hackedNetwork = false,
                safeCode = generateSafeCode(),
                openedSafe = false,
                safeNet = -1
            }
            print(string.format("[DEBUG] Initialized GlobalState for store %d", index))
        end
    end
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

    local isRobbable = Config.Locations[closestStore].robbable
    updateStore(closestStore, "active", true)
    -- main.lua (server-side)
    local storeIndex = getClosestStore(tillCoords) -- Already calculated on the server
    TriggerClientEvent("ff_shoprobbery:client:robTill", src, netId, tillCoords, tillRotation, isRobbable, storeIndex)
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
-- Handle safe looting without cancellation
RegisterNetEvent("ff_shoprobbery:server:lootedSafe", function(safeCoords)
    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(safeCoords)
    if not closestStore then return end
    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)]
    if not storeData or not storeData.active or not storeData.hackedNetwork or storeData.openedSafe then return end

    updateStore(closestStore, "openedSafe", true)

    -- Award safe items
    for _, item in ipairs(Config.SafeItems) do
        local chance = math.random(1, 100)
        if chance <= item.chance then
            local amount = math.random(item.min, item.max)
            AddItem(src, item.item, amount)
            SendLog(src, GetPlayerName(src), locale("logs.item.title"), string.format(locale("logs.item.description"), amount, item.item, closestStore), Colours.FiveForgeGreen)
        end
    end

    -- End robbery gracefully with cooldown
    finishRobbery(closestStore, src, false, true)
    Notify(src, "Safe looted successfully", "success")
    SendLog(src, GetPlayerName(src), locale("logs.safe.title"), string.format(locale("logs.safe.description"), closestStore), Colours.FiveForgeGreen)
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
            local success, netId = lib.callback.await("ff_shoprobbery:createSafe", src, Config.Locations[i].safe)
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
                    if not IsEntityDead(pedEntity) then
                        -- Make ped flee before deletion
                        ClearPedTasks(pedEntity)
                        TaskReactAndFleePed(pedEntity, PlayerPedId())
                        -- Delete after a delay to allow fleeing
                        SetTimeout(10000, function() -- 10 seconds to flee
                            if pedEntity and DoesEntityExist(pedEntity) and not IsEntityDead(pedEntity) then
                                DeleteEntity(pedEntity)
                            end
                        end)
                    -- else, let dead ped persist
                    end
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
            local success, netId = lib.callback.await("ff_shoprobbery:createSafe", src, Config.Locations[index].safe)
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

-- Handle cancellation for pre-bag scenarios and ped deaths
RegisterNetEvent("ff_shoprobbery:server:cancelRobbery", function(tillCoords, beforeBagDropped)
    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(tillCoords)
    if not closestStore or not GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].active then return end

    finishRobbery(closestStore, src, beforeBagDropped, not beforeBagDropped)
    TriggerClientEvent("ff_shoprobbery:client:cancelRobbery", -1)
    Notify(src, beforeBagDropped and "Robbery cancelled: you left the area" or "Robbery cancelled: clerk killed", "error")
    SendLog(src, GetPlayerName(src), locale("logs.cancelled.title"), string.format(locale("logs.cancelled.description"), closestStore), Colours.FiveForgeRed)
end)

RegisterNetEvent("ff_shoprobbery:server:finishNonRobbableRobbery", function(storeIndex)
    if not storeIndex or type(storeIndex) ~= "number" then return end
    local src = source
    local player = GetPlayer(src) -- Your framework's player retrieval function
    if not player then return end
    finishRobbery(storeIndex, src) -- Assuming this function exists and uses storeIndex
end)

-- Start cooldown without cancellation for post-bag proximity
RegisterNetEvent("ff_shoprobbery:server:startCooldown", function(tillCoords)
    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(tillCoords)
    if not closestStore or not GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].active then return end

    finishRobbery(closestStore, src, false, true)
    Notify(src, "You left the store, cooldown started", "info")
    SendLog(src, GetPlayerName(src), locale("logs.cooldown.title"), string.format(locale("logs.cooldown.description"), closestStore), Colours.FiveForgeBlue)
end)