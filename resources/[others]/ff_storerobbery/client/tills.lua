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

    RobberyAlert(tillCoords)
    TriggerServerEvent("ff_shoprobbery:server:removeTill", tillCoords)

    -- Play animation directly from ped's current position
    lib.requestAnimDict("mp_am_hold_up")
    TaskPlayAnim(entity, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 2, 0, false, false, false)
    while not IsEntityPlayingAnim(entity, "mp_am_hold_up", "holdup_victim_20s", 3) do Wait(0) end

    -- Swap the cashier model to the damaged version to simulate opening during animation
    CreateModelSwap(GetEntityCoords(cashRegister), 0.5, `prop_till_01`, `prop_till_01_dam`, false)

    local timer = GetGameTimer() + 10800
    while timer >= GetGameTimer() do
        if IsEntityDead(entity) then
            break
        end
        Wait(0)
    end

    if not IsEntityDead(entity) then
        -- Create the plastic bag (only one instance)
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
        else
            DeleteObject(bag)
        end
    end

    -- Ped reacts and flees as if gun is aimed
    TaskReactAndFleePed(entity, cache.ped)
    TriggerServerEvent("ff_shoprobbery:server:restoreTill", tillCoords)
end)

--- @param tillCoords vector3
RegisterNetEvent("ff_shoprobbery:client:removeTill", function(tillCoords)
    if not tillCoords then return end

    -- Replace the default till model to a network scene supported one
    CreateModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, `prop_till_01`, `p_till_01_s`, true)
end)

--- @param tillCoords vector3
RegisterNetEvent("ff_shoprobbery:client:restoreTill", function(tillCoords)
    if not tillCoords then return end
    
    -- Return the default till model instead of the network scene supported one
    CreateModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, `p_till_01_s`, `prop_till_01`, true)
    Wait(1000)
    RemoveModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, `prop_till_01`, `p_till_01_s`, true)
    RemoveModelSwap(tillCoords.x, tillCoords.y, tillCoords.z, 0.5, `p_till_01_s`, `prop_till_01`, true)
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