---@param clerkNet number
---@param tillCoords vector3
---@param tillRotation vector3
RegisterNetEvent("ff_shoprobbery:client:robTill", function(clerkNet, tillCoords, tillRotation)
    if not clerkNet or not NetworkDoesNetworkIdExist(clerkNet) then return end

    local entity = NetworkGetEntityFromNetworkId(clerkNet)
    if not entity or not DoesEntityExist(entity) then return end

    if not lib.requestModel(`p_poly_bag_01_s`) then return end

    local pedCoords = GetEntityCoords(entity, false)
    local cashRegister = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 5.0, `prop_till_01`, false, false, false)
    if not cashRegister or not DoesEntityExist(cashRegister) then return end

    -- Trigger robbery alert
    RobberyAlert(tillCoords)

    -- Play holdup animation
    lib.requestAnimDict("mp_am_hold_up")
    TaskPlayAnim(entity, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 2, 0, false, false, false)
    while not IsEntityPlayingAnim(entity, "mp_am_hold_up", "holdup_victim_20s", 3) do Wait(0) end

    local timer = GetGameTimer() + 10800
    while timer >= GetGameTimer() do
        if IsEntityDead(entity) then
            break
        end
        Wait(0)
    end

    if not IsEntityDead(entity) then
        -- Break the closest cash register after animation progresses
        local cashRegisterCoords = GetEntityCoords(cashRegister, false)
        CreateModelSwap(cashRegisterCoords.x, cashRegisterCoords.y, cashRegisterCoords.z, 0.5, GetHashKey('prop_till_01'), GetHashKey('prop_till_01_dam'), false)

        -- Small delay before creating bag
        timer = GetGameTimer() + 200
        while timer >= GetGameTimer() do
            if IsEntityDead(entity) then
                break
            end
            Wait(0)
        end

        if not IsEntityDead(entity) then
            -- Create and attach bag
            local bag = CreateObject(`p_poly_bag_01_s`, pedCoords.x, pedCoords.y, pedCoords.z, true, false, false)
            AttachEntityToEntity(bag, entity, GetPedBoneIndex(entity, 60309), 0.1, -0.11, 0.08, 0.0, -75.0, -75.0, 1, 1, 0, 0, 2, 1)
            timer = GetGameTimer() + 10000
            while timer >= GetGameTimer() do
                if IsEntityDead(entity) then
                    break
                end
                Wait(0)
            end

            if not IsEntityDead(entity) then
                DetachEntity(bag, true, false)
                timer = GetGameTimer() + 75
                while timer >= GetGameTimer() do
                    if IsEntityDead(entity) then
                        break
                    end
                    Wait(0)
                end
                SetEntityHeading(bag, tillRotation.z)
                ApplyForceToEntity(bag, 3, vector3(0.0, 50.0, 0.0), 0.0, 0.0, 0.0, 0, true, true, false, false, true)
                TriggerServerEvent("ff_shoprobbery:server:cashDropped", GetEntityCoords(bag, false), GetEntityRotation(bag, 2))
                DeleteObject(bag) -- Delete the bag object to prevent duplication with pickup
            else
                DeleteObject(bag)
            end

            -- Play cower animations
            lib.requestAnimDict("mp_am_hold_up")
            TaskPlayAnim(entity, "mp_am_hold_up", "cower_intro", 8.0, -8.0, -1, 0, 0, false, false, false)
            timer = GetGameTimer() + 2500
            while timer >= GetGameTimer() do Wait(0) end
            TaskPlayAnim(entity, "mp_am_hold_up", "cower_loop", 8.0, -8.0, -1, 1, 0, false, false, false)
            local stop = GetGameTimer() + 120000
            while stop >= GetGameTimer() do
                Wait(50)
            end
            if IsEntityPlayingAnim(entity, "mp_am_hold_up", "cower_loop", 3) then
                ClearPedTasks(entity)
            end
        end
    end

    -- Ped reacts and flees as if gun is aimed
    TaskReactAndFleePed(entity, cache.ped)
    TriggerServerEvent("ff_shoprobbery:server:restoreTill", cashRegisterCoords)
end)

--- @param tillCoords vector3
RegisterNetEvent("ff_shoprobbery:client:restoreTill", function(tillCoords)
    if not tillCoords then return end
    
    -- Restore the default till model
    CreateModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, GetHashKey('prop_till_01_dam'), GetHashKey('prop_till_01'), false)
    Wait(1000)
    RemoveModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, GetHashKey('prop_till_01_dam'), GetHashKey('prop_till_01'), false)
end)

--- Thread for handling picking up the dropped loot from the till
local moneyPickup = nil
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

--- @param pickupCoords vector3
--- @param pickupRotation vector3
RegisterNetEvent("ff_shoprobbery:client:cashDropped", function(pickupCoords, pickupRotation)
    if not pickupCoords then return end
    if not pickupRotation then return end
    -- Load the model into memory
    lib.requestModel(`p_poly_bag_01_s`)

    -- Create the loot pickup
    moneyPickup = CreatePickupRotate(`PICKUP_MONEY_MED_BAG`, pickupCoords.x, pickupCoords.y, pickupCoords.z, pickupRotation.x, pickupRotation.y, pickupRotation.z, 8, 1.0, 24, true, `p_poly_bag_01_s`)
    -- Wait until the pickup exists
    local exists = lib.waitFor(function()
        if DoesPickupExist(moneyPickup) then return true end
    end)

    if not exists then return end

    -- Start the pickup collection thread
    pickupTask()

    SetModelAsNoLongerNeeded(`p_poly_bag_01_s`)
end)

--- @param pickupCoords vector3
RegisterNetEvent("ff_shoprobbery:client:cashCollected", function(pickupCoords)
    if not moneyPickup or not pickupCoords then return end
    local currPickupCoords = GetPickupCoords(moneyPickup)
    if currPickupCoords ~= pickupCoords then return end
    
    -- Remove the pickup since someone else has picked it up
    RemovePickup(moneyPickup)
    moneyPickup = nil
end)