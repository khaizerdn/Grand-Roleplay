lib.locale()

local safe = require "client.safe"
local network = require "client.network"
require "client.peds"

-- Local variables
local activeRobberyStates = {}
local playerProximity = {}
local moneyPickup = nil

-- Initialize proximity tracking
for index, _ in ipairs(Config.Locations) do
    playerProximity[index] = false
end

-- Functions
local function getPedInFront()
    local pedCoords = GetEntityCoords(cache.ped, false)
    local rayEnd = pedCoords + (GetEntityForwardVector(cache.ped) * 5.0)
    local shapeTest = StartShapeTestCapsule(pedCoords.x, pedCoords.y, pedCoords.z, rayEnd.x, rayEnd.y, rayEnd.z, 1.0, 4, cache.ped, 7)
    local _, hit, _, _, entity = GetShapeTestResult(shapeTest)
    return hit, entity
end

local function pickupTask()
    if not moneyPickup then return end
    CreateThread(function()
        while DoesPickupExist(moneyPickup) do
            local playerPos = GetEntityCoords(cache.ped, false)
            local pickupPos = GetPickupCoords(moneyPickup)
            if #(playerPos - pickupPos) < 1.5 then
                if HasPickupBeenCollected(moneyPickup) then
                    TriggerServerEvent("ff_shoprobbery:server:cashCollected", pickupPos)
                    return
                end
            end
            Wait(5)
        end
    end)
end

local function startClerkTask()
    CreateThread(function()
        local sleep = 1000
        while true do
            local weapon = cache.weapon
            if weapon and weapon ~= `WEAPON_UNARMED` then
                sleep = 500
                if IsControlPressed(0, 25) then
                    local hit, entity = getPedInFront()
                    if hit and GetEntityType(entity) == 1 and not IsPedAPlayer(entity) then
                        if Entity(entity).state["ff_shoprobbery:registerPed"] then
                            local storeIndex = Entity(entity).state.storeIndex
                            if storeIndex then
                                local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]
                                if storeData and not storeData.active then
                                    local isNonRobbable = (storeData.nonRobbableUntil or -1) > GetGameTimer() or not Config.Locations[storeIndex].robbable
                                    if not isNonRobbable and storeData.cooldown == -1 then
                                        local clerkPos = GetEntityCoords(entity, false)
                                        local till = GetClosestObjectOfType(clerkPos.x, clerkPos.y, clerkPos.z, 5.0, `prop_till_01`, false, false, false)
                                        if till and DoesEntityExist(till) then
                                            local tillCoords = GetOffsetFromEntityInWorldCoords(till, 0.0, 0.0, -0.12)
                                            local tillRotation = GetEntityRotation(till, 2)
                                            print(string.format("[DEBUG] Initiating robbery for store %d at coords %s", storeIndex, json.encode(tillCoords)))
                                            TriggerServerEvent("ff_shoprobbery:server:startedRobbery", tillCoords, tillRotation)
                                            Wait(5000)
                                        else
                                            print(string.format("[DEBUG] No till found for store %d at ped coords %s", storeIndex, json.encode(clerkPos)))
                                        end
                                    else
                                        print(string.format("[DEBUG] Store %d not robbable: nonRobbableUntil=%s, cooldown=%s, config_robbable=%s", storeIndex, tostring(storeData.nonRobbableUntil or "nil"), tostring(storeData.cooldown), tostring(Config.Locations[storeIndex].robbable)))
                                        local clerkNet = NetworkGetNetworkIdFromEntity(entity)
                                        TriggerEvent("ff_shoprobbery:client:robTill", clerkNet, GetEntityCoords(entity, false), GetEntityRotation(entity, 2), false, storeIndex)
                                        Wait(5000)
                                    end
                                else
                                    print(string.format("[DEBUG] Store %d not robbable: storeData=%s, active=%s, nonRobbableUntil=%s", storeIndex, tostring(storeData), tostring(storeData and storeData.active), tostring(storeData and storeData.nonRobbableUntil or "nil")))
                                end
                            else
                                print("[DEBUG] Ped has no storeIndex")
                            end
                        else
                            print("[DEBUG] Ped not registered for robbery")
                        end
                    end
                end
            else
                sleep = 1000
            end
            Wait(sleep)
        end
    end)
end

-- RegisterNetEvent handlers
RegisterNetEvent("ff_shoprobbery:client:robTill", function(clerkNet, tillCoords, tillRotation, isRobbable, storeIndex)
    if not clerkNet or not NetworkDoesNetworkIdExist(clerkNet) or not storeIndex then return end

    local entity = NetworkGetEntityFromNetworkId(clerkNet)
    if not entity or not DoesEntityExist(entity) or not lib.requestModel(`p_poly_bag_01_s`) then return end

    local pedCoords = GetEntityCoords(entity)
    local cashRegister = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 3.0, `prop_till_01`, false, false, false)
    if not cashRegister or not DoesEntityExist(cashRegister) then return end

    if not isRobbable then
        if activeRobberyStates[storeIndex] then return end
        activeRobberyStates[storeIndex] = true
    
        RobberyAlert(tillCoords)
        lib.requestAnimDict("mp_am_hold_up")
        TaskPlayAnim(entity, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 2, 0, false, false, false)
        Wait(5000)
        FreezeEntityPosition(entity, false)
        TaskReactAndFleePed(entity, cache.ped)
    
        CreateThread(function()
            while true do
                local playerCoords = GetEntityCoords(cache.ped)
                local distance = #(playerCoords - pedCoords)
                if distance > 30.0 then
                    activeRobberyStates[storeIndex] = nil
                    if IsEntityDead(entity) then
                        DeleteEntity(entity)
                    end
                    TriggerServerEvent("ff_shoprobbery:server:resetNonRobbableStore", storeIndex)
                    break
                end
                Wait(100)
            end
        end)
        return
    end

    RobberyAlert(tillCoords)
    lib.requestAnimDict("mp_am_hold_up")
    TaskPlayAnim(entity, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 2, 0, false, false, false)
    while not IsEntityPlayingAnim(entity, "mp_am_hold_up", "holdup_victim_20s", 3) do Wait(0) end

    local timer = GetGameTimer() + 10800
    local bagDropped = false

    while timer >= GetGameTimer() do
        if IsEntityDead(entity) then
            TriggerServerEvent("ff_shoprobbery:server:cancelRobbery", tillCoords, false)
            return
        end

        local playerCoords = GetEntityCoords(cache.ped)
        if #(playerCoords - pedCoords) > 30.0 then
            TriggerServerEvent("ff_shoprobbery:server:cancelRobbery", tillCoords, true)
            ClearPedTasks(entity)
            DeleteEntity(entity)
            return
        end
        Wait(0)
    end

    if not IsEntityDead(entity) then
        local cashRegisterCoords = GetEntityCoords(cashRegister)
        CreateModelSwap(cashRegisterCoords.x, cashRegisterCoords.y, cashRegisterCoords.z, 0.5, `prop_till_01`, `prop_till_01_dam`, false)

        local timer = GetGameTimer() + 200
        while timer >= GetGameTimer() do
            if IsEntityDead(entity) then
                TriggerServerEvent("ff_shoprobbery:server:cancelRobbery", tillCoords, false)
                return
            end
            Wait(0)
        end

        if not IsEntityDead(entity) then
            local bag = CreateObject(`p_poly_bag_01_s`, pedCoords.x, pedCoords.y, pedCoords.z, true, false, false)
            AttachEntityToEntity(bag, entity, GetPedBoneIndex(entity, 60309), 0.1, -0.11, 0.08, 0.0, -75.0, -75.0, 1, 1, 0, 0, 2, 1)
            timer = GetGameTimer() + 10000
            while timer >= GetGameTimer() do
                if IsEntityDead(entity) then
                    TriggerServerEvent("ff_shoprobbery:server:cancelRobbery", tillCoords, false)
                    DeleteObject(bag)
                    return
                end
                Wait(0)
            end

            if not IsEntityDead(entity) then
                DetachEntity(bag, true, false)
                timer = GetGameTimer() + 75
                while timer >= GetGameTimer() do
                    if IsEntityDead(entity) then
                        TriggerServerEvent("ff_shoprobbery:server:cancelRobbery", tillCoords, false)
                        DeleteObject(bag)
                        return
                    end
                    Wait(0)
                end
                SetEntityHeading(bag, tillRotation.z)
                ApplyForceToEntity(bag, 3, vector3(0.0, 50.0, 0.0), 0.0, 0.0, 0.0, 0, true, true, false, false, true)
                TriggerServerEvent("ff_shoprobbery:server:cashDropped", GetEntityCoords(bag), GetEntityRotation(bag, 2))
                bagDropped = true

                CreateThread(function()
                    while true do
                        local playerCoords = GetEntityCoords(cache.ped)
                        if #(playerCoords - pedCoords) > 30.0 then
                            TriggerServerEvent("ff_shoprobbery:server:startCooldown", tillCoords)
                            break
                        end
                        Wait(100)
                    end
                end)
            else
                DeleteObject(bag)
            end

            FreezeEntityPosition(entity, false)
            TaskReactAndFleePed(entity, cache.ped)
        end
    end

    if not IsEntityDead(entity) and not bagDropped then
        ClearPedTasks(entity)
        FreezeEntityPosition(entity, false)
        SetEntityAsMissionEntity(entity, true, true)
        TriggerServerEvent("ff_shoprobbery:server:restoreTill", GetEntityCoords(cashRegister))
    end
end)

RegisterNetEvent("ff_shoprobbery:client:restoreTill", function(tillCoords)
    if not tillCoords then return end
    CreateModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, GetHashKey('prop_till_01_dam'), GetHashKey('prop_till_01'), false)
    Wait(1000)
    RemoveModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, GetHashKey('prop_till_01_dam'), GetHashKey('prop_till_01'), false)
end)

RegisterNetEvent("ff_shoprobbery:client:cashDropped", function(pickupCoords, pickupRotation)
    if not pickupCoords or not pickupRotation then return end
    lib.requestModel(`p_poly_bag_01_s`)
    moneyPickup = CreatePickupRotate(`PICKUP_MONEY_MED_BAG`, pickupCoords.x, pickupCoords.y, pickupCoords.z, pickupRotation.x, pickupRotation.y, pickupRotation.z, 8, 1.0, 24, true, `p_poly_bag_01_s`)
    local exists = lib.waitFor(function()
        if DoesPickupExist(moneyPickup) then return true end
    end)
    if not exists then return end
    pickupTask()
    SetModelAsNoLongerNeeded(`p_poly_bag_01_s`)
end)

RegisterNetEvent("ff_shoprobbery:client:cashCollected", function(pickupCoords)
    if not moneyPickup or not pickupCoords then return end
    local currPickupCoords = GetPickupCoords(moneyPickup)
    if currPickupCoords ~= pickupCoords then return end
    RemovePickup(moneyPickup)
    moneyPickup = nil
end)

RegisterNetEvent("ff_shoprobbery:client:reset", startClerkTask)

RegisterNetEvent("ff_shoprobbery:client:disableNetwork", function(index)
    if not index or type(index) ~= "number" then return end
end)

-- Event handlers
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
end)

-- State bag handlers
for i = 1, #Config.Locations do
    AddStateBagChangeHandler(string.format("ff_shoprobbery:store:%s", i), "", function(bagName, key, value, reserved, replicated)
        Debug("Store data updated for store " .. i .. ": " .. json.encode(value, { indent = true }), DebugTypes.Info)
        if value and value.robbedTill and not value.hackedNetwork then
            Wait(100)
            Debug("Triggering network interaction for store " .. i, DebugTypes.Info)
            network.createInteract(i)
        elseif value and value.hackedNetwork and not value.openedSafe then
            Wait(100)
            Debug("Triggering safe interaction for store " .. i, DebugTypes.Info)
            safe.createInteract(i, value.safeNet)
        end
    end)
end

-- Callback registrations
lib.callback.register('ff_shoprobbery:createSafe', function(safePosition)
    return safe.create(safePosition)
end)

lib.callback.register('ff_shoprobbery:isPedDead', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity and DoesEntityExist(entity) then
        return IsEntityDead(entity)
    end
    return false
end)

-- Proximity monitoring thread
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        for index, location in ipairs(Config.Locations) do
            local storePos = vector3(location.ped.x, location.ped.y, location.ped.z)
            local distance = #(playerPos - storePos)
            local isInProximity = distance < 30.0
            if isInProximity and not playerProximity[index] then
                TriggerServerEvent("ff_shoprobbery:server:enterProximity", index)
                playerProximity[index] = true
            elseif not isInProximity and playerProximity[index] then
                TriggerServerEvent("ff_shoprobbery:server:leaveProximity", index)
                playerProximity[index] = false
            end
        end
        Wait(1000)
    end
end)

-- Initialize clerk task
startClerkTask()