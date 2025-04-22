AddStateBagChangeHandler("ff_shoprobbery:registerPed", '', function(entity, _, value)
    local entity, netId = GetEntityAndNetIdFromBagName(entity)
    if entity then
        -- Set random clothing
        SetPedRandomComponentVariation(entity, 1)

        -- Disable fleeing and make sure they remain still
        SetEntityAsMissionEntity(entity, true, true)
        SetPedCanRagdoll(entity, false)
        FreezeEntityPosition(entity, true)
        TaskSetBlockingOfNonTemporaryEvents(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)
        SetPedFleeAttributes(entity, 0, false)
        SetPedCombatAttributes(entity, 17, true)
        SetPedSeeingRange(entity, 0)
        SetPedDefaultComponentVariation(entity)
        ClearPedTasks(entity)
    end
end)