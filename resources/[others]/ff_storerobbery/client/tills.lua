--- @param clerkNet number
--- @param tillCoords vector3
--- @param tillRotation vector3
RegisterNetEvent("ff_shoprobbery:client:robTill", function(clerkNet, tillCoords, tillRotation)
    if not clerkNet or not NetworkDoesNetworkIdExist(clerkNet) then return end

    local entity = NetworkGetEntityFromNetworkId(clerkNet)
    if not entity or not DoesEntityExist(entity) then return end

    if not lib.requestModel(`p_till_01_s`) then return end
    if not lib.requestModel(`p_poly_bag_01_s`) then return end

    local till = GetClosestObjectOfType(tillCoords.x, tillCoords.y, tillCoords.z, 1.0, `prop_till_01`, false, false, false)
    if not till or not DoesEntityExist(till) then return end

    local _movePos = GetOffsetFromEntityInWorldCoords(till, 0.0, -1.0, 0.0)
    FreezeEntityPosition(entity, false)
    TaskGoStraightToCoord(entity, _movePos.x, _movePos.y, _movePos.z, 1.0, 3000, GetEntityHeading(till), 0.0)

    while #(GetEntityCoords(entity, false) - _movePos) > 0.3 do
        Wait(100)
    end

    local till = CreateObject(`p_till_01_s`, tillCoords.x, tillCoords.y, tillCoords.z, true, false, false)
    local bag = CreateObject(`p_poly_bag_01_s`, tillCoords.x, tillCoords.y, tillCoords.z, true, false, false)
    
    local exists = lib.waitFor(function()
        if DoesEntityExist(till) and DoesEntityExist(bag) then return true end
    end)

    if not exists then return end

    RobberyAlert(tillCoords)
    TriggerServerEvent("ff_shoprobbery:server:removeTill", tillCoords)

    local scene = NetworkCreateSynchronisedScene(tillCoords.x, tillCoords.y, tillCoords.z, tillRotation.x, tillRotation.y, tillRotation.z - 180.0, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(
        entity,
        scene,
        "mp_am_hold_up",
        "holdup_victim_20s",
        1.5,
        -4.0,
        1,
        16,
        1148846080,
        0
    )
    
    NetworkAddEntityToSynchronisedScene(
        till,
        scene,
        "mp_am_hold_up",
        "holdup_victim_20s_till",
        1.0,
        1.0,
        1
    )
    
    NetworkAddEntityToSynchronisedScene(
        bag,
        scene,
        "mp_am_hold_up",
        "holdup_victim_20s_bag",
        1.0,
        1.0,
        1
    )

    NetworkStartSynchronisedScene(scene)

    local function finishTill(cancelled)
        NetworkStopSynchronisedScene(scene)
        ClearPedTasks(entity)
        FreezeEntityPosition(entity, true)
        DeleteEntity(till)
        if cancelled then
            DeleteEntity(bag)
            TriggerServerEvent("ff_shoprobbery:server:cancelRobbery", tillCoords)
        end
        TriggerServerEvent("ff_shoprobbery:server:restoreTill", tillCoords)
    end

    -- Monitor ped health and cancel immediately if dead
    local isCancelled = false
    local isMonitoring = true
    CreateThread(function()
        while isMonitoring do
            if IsEntityDead(entity) then
                isCancelled = true
                -- Cancel progress bar only if active
                if Config.Progress == "ox_lib_bar" or Config.Progress == "ox_lib_circle" then
                    exports.ox_lib:cancelProgress()
                elseif Config.Progress == "mythic" then
                    -- Replace with actual mythic cancel function if available
                    exports.mythic:cancelProgress() -- Adjust if mythic has a specific cancel function
                end
                -- Stop animation and clean up
                finishTill(true)
                break
            end
            Wait(100)
        end
    end)

    if Config.Progress == "ox_lib_bar" then
        ProgressBar({
            duration = 21566,
            label = locale('progress.robbing'),
            useWhileDead = false,
            allowRagdoll = true,
            allowSwimming = false,
            allowCuffed = false,
            allowFalling = true,
            canCancel = true,
        }, function(cancelled)
            -- Stop health monitoring on completion
            isMonitoring = false
            if isCancelled or cancelled then
                finishTill(true)
            else
                finishTill(false)
                TriggerServerEvent("ff_shoprobbery:server:cashDropped", GetEntityCoords(bag, false), GetEntityRotation(bag, 2))
            end
        end)
    elseif Config.Progress == "ox_lib_circle" then
        ProgressBar({
            duration = 21566,
            label = locale('progress.robbing'),
            position = "bottom",
            useWhileDead = false,
            allowRagdoll = true,
            allowSwimming = false,
            allowCuffed = false,
            allowFalling = true,
            canCancel = true,
        }, function(cancelled)
            -- Stop health monitoring on completion
            isMonitoring = false
            if isCancelled or cancelled then
                finishTill(true)
            else
                finishTill(false)
                TriggerServerEvent("ff_shoprobbery:server:cashDropped", GetEntityCoords(bag, false), GetEntityRotation(bag, 2))
            end
        end)
    elseif Config.Progress == "mythic" then
        ProgressBar({
            name = "rob_till",
            duration = 21566,
            label = locale('progress.robbing'),
            useWhileDead = false,
            canCancel = true,
            disarm = false
        }, function(cancelled)
            -- Stop health monitoring on completion
            isMonitoring = false
            if isCancelled or cancelled then
                finishTill(true)
            else
                finishTill(false)
                TriggerServerEvent("ff_shoprobbery:server:cashDropped", GetEntityCoords(bag, false), GetEntityRotation(bag, 2))
            end
        end)
    end
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