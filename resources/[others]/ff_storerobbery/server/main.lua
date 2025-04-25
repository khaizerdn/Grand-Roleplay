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
    return string.format("%04d", number)
end

local function updateStore(storeIndex, key, value)
    if not storeIndex or type(storeIndex) ~= "number" then return end
    if not key or type(key) ~= "string" then return end
    if value == nil then return end

    local storeKey = string.format("ff_shoprobbery:store:%s", storeIndex)
    local storeData = GlobalState[storeKey] or {}
    
    storeData[key] = value
    GlobalState[storeKey] = storeData
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
    if not closestStore then return Notify(src, "Store not found", "error")
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
    local storeIndex = getClosestStore(tillCoords)
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
RegisterNetEvent("ff_shoprobbery:server:lootedSafe", function(safeCoords)
    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(safeCoords)
    if not closestStore then return end
    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)]
    if not storeData or not storeData.active or not storeData.hackedNetwork or storeData.openedSafe then return end

    updateStore(closestStore, "openedSafe", true)

    for _, item in ipairs(Config.SafeItems) do
        local chance = math.random(1, 100)
        if chance <= item.chance then
            local amount = math.random(item.min, item.max)
            AddItem(src, item.item, amount)
            SendLog(src, GetPlayerName(src), locale("logs.item.title"), string.format(locale("logs.item.description"), amount, item.item, closestStore), Colours.FiveForgeGreen)
        end
    end

    Notify(src, "Safe looted successfully", "success")
    SendLog(src, GetPlayerName(src), locale("logs.safe.title"), string.format(locale("logs.safe.description"), closestStore), Colours.FiveForgeGreen)
end)

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
        peds.create(Config.Locations[i].ped, i)
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
            peds.create(Config.Locations[i].ped, i)
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

RegisterNetEvent("ff_shoprobbery:server:cancelRobbery", function(tillCoords, beforeBagDropped)
    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(tillCoords)
    if not closestStore then return end

    local storeKey = string.format("ff_shoprobbery:store:%s", closestStore)
    local storeData = GlobalState[storeKey]
    if not storeData or not storeData.active then return end

    -- Reset store states to make it robbable again
    storeData.active = false
    storeData.robbedTill = false
    storeData.hackedNetwork = false
    storeData.openedSafe = false
    local safeNet = storeData.safeNet
    storeData.safeNet = -1
    storeData.cooldown = -1
    storeData.nonRobbableUntil = -1
    GlobalState[storeKey] = storeData

    -- Delete safe if it exists
    if safeNet and safeNet > 0 then
        local safeEntity = NetworkGetEntityFromNetworkId(safeNet)
        if safeEntity and DoesEntityExist(safeEntity) then
            DeleteEntity(safeEntity)
        end
    end

    -- Handle ped: delete only if dead, then spawn a new one
    local pedNet = peds.getClosest(Config.Locations[closestStore].ped)
    if pedNet then
        local pedEntity = NetworkGetEntityFromNetworkId(pedNet)
        if pedEntity and DoesEntityExist(pedEntity) then
            local isDead = lib.callback.await('ff_shoprobbery:isPedDead', src, pedNet)
            if isDead then
                DeleteEntity(pedEntity)
            end
        end
    end

    -- Always spawn a new ped for future interaction
    peds.create(Config.Locations[closestStore].ped, closestStore)

    -- Trigger client events to update client-side states
    TriggerClientEvent("ff_shoprobbery:client:disableNetwork", -1, closestStore)
    TriggerClientEvent("ff_shoprobbery:client:cancelRobbery", -1)

    -- Send notifications and logs
    local reason = beforeBagDropped and "you left the area" or "clerk killed"
    Notify(src, "Robbery cancelled: " .. reason, "error")
    SendLog(src, GetPlayerName(src), locale("logs.cancelled.title"), string.format(locale("logs.cancelled.description"), closestStore), Colours.FiveForgeRed)
end)

RegisterNetEvent("ff_shoprobbery:server:startCooldown", function(tillCoords)
    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local closestStore = getClosestStore(tillCoords)
    if not closestStore then return end

    local storeKey = string.format("ff_shoprobbery:store:%s", closestStore)
    local storeData = GlobalState[storeKey]
    if not storeData then return end

    -- Reset store states to remove hacking and safe interactions
    storeData.active = false
    storeData.robbedTill = false
    storeData.hackedNetwork = false
    storeData.openedSafe = false
    local safeNet = storeData.safeNet
    storeData.safeNet = -1
    GlobalState[storeKey] = storeData

    -- Delete safe if it exists
    if safeNet and safeNet > 0 then
        local safeEntity = NetworkGetEntityFromNetworkId(safeNet)
        if safeEntity and DoesEntityExist(safeEntity) then
            DeleteEntity(safeEntity)
        end
    end

    -- Handle ped: delete only if dead, then spawn a new one
    local pedNet = peds.getClosest(Config.Locations[closestStore].ped)
    if pedNet then
        local pedEntity = NetworkGetEntityFromNetworkId(pedNet)
        if pedEntity and DoesEntityExist(pedEntity) then
            local isDead = lib.callback.await('ff_shoprobbery:isPedDead', src, pedNet)
            if isDead then
                DeleteEntity(pedEntity)
            end
        end
    end

    -- Spawn a new ped for future interaction
    peds.create(Config.Locations[closestStore].ped, closestStore)

    -- Set store as not robbable by setting cooldown
    local cooldownEnd = GetGameTimer() + Config.StoreCooldown * 1000
    storeData.cooldown = cooldownEnd
    storeData.nonRobbableUntil = cooldownEnd
    GlobalState[storeKey] = storeData

    -- Set timeout to clear cooldown states after the cooldown period
    SetTimeout(Config.StoreCooldown * 1000, function()
        local updatedStoreData = GlobalState[storeKey]
        if updatedStoreData then
            updatedStoreData.cooldown = -1
            updatedStoreData.nonRobbableUntil = -1
            GlobalState[storeKey] = updatedStoreData
        end
    end)

    -- Notify the player and log the event
    Notify(src, "You left the store, cooldown started", "info")
    SendLog(src, GetPlayerName(src), locale("logs.cooldown.title"), string.format(locale("logs.cooldown.description"), closestStore), Colours.FiveForgeBlue)
end)

local storeProximityPlayers = {}
for index, _ in ipairs(Config.Locations) do
    storeProximityPlayers[index] = {}
end

RegisterNetEvent("ff_shoprobbery:server:enterProximity", function(storeIndex)
    local src = source
    if not storeProximityPlayers[storeIndex] then return end
    table.insert(storeProximityPlayers[storeIndex], src)
end)

RegisterNetEvent("ff_shoprobbery:server:leaveProximity", function(storeIndex)
    local src = source
    if not storeProximityPlayers[storeIndex] then return end
    for i, playerSrc in ipairs(storeProximityPlayers[storeIndex]) do
        if playerSrc == src then
            table.remove(storeProximityPlayers[storeIndex], i)
            break
        end
    end
    if #storeProximityPlayers[storeIndex] == 0 then
        local pedNet = peds.getClosest(Config.Locations[storeIndex].ped)
        if pedNet then
            local pedEntity = NetworkGetEntityFromNetworkId(pedNet)
            if pedEntity and DoesEntityExist(pedEntity) and GetEntityHealth(pedEntity) <= 0 then
                DeleteEntity(pedEntity)
                peds.create(Config.Locations[storeIndex].ped, storeIndex)
                print(string.format("[DEBUG] Respawned ped for store %d after last player left proximity", storeIndex))
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for storeIndex, players in pairs(storeProximityPlayers) do
        for i, playerSrc in ipairs(players) do
            if playerSrc == src then
                table.remove(storeProximityPlayers[storeIndex], i)
                if #storeProximityPlayers[storeIndex] == 0 then
                    local pedNet = peds.getClosest(Config.Locations[storeIndex].ped)
                    if pedNet then
                        local pedEntity = NetworkGetEntityFromNetworkId(pedNet)
                        if pedEntity and DoesEntityExist(pedEntity) and IsEntityDead(pedEntity) then
                            DeleteEntity(pedEntity)
                            peds.create(Config.Locations[storeIndex].ped, storeIndex)
                            print(string.format("[DEBUG] Respawned ped for store %d after player disconnected", storeIndex))
                        end
                    end
                end
                break
            end
        end
    end
end)

RegisterNetEvent("ff_shoprobbery:server:resetNonRobbableStore", function(storeIndex)
    if not storeIndex or type(storeIndex) ~= "number" then return end

    peds.create(Config.Locations[storeIndex].ped, storeIndex)
    print(string.format("[DEBUG] Reset non-robbable store %d and respawned ped", storeIndex))

    SendLog(source, GetPlayerName(source), locale("logs.reset_nonrobbable.title"), string.format(locale("logs.reset_nonrobbable.description"), storeIndex), Colours.FiveForgeBlue)
end)