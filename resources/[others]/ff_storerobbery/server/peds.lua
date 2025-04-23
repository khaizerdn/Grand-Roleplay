local peds = {
    created = {}
}

--- Create shop peds on server start
---@param location vector4
---@param storeIndex number
function peds.create(location, storeIndex)
    local modelHash = Config.Peds[math.random(1, #Config.Peds)]
    local ped = CreatePed(4, modelHash, location.x, location.y, location.z, location.w, true, false)
    local netId = NetworkGetNetworkIdFromEntity(ped)

    if netId and netId > 0 then
        local success = false
        for i = 1, 3 do -- Retry up to 3 times
            Entity(ped).state:set("ff_shoprobbery:registerPed", true, true)
            Entity(ped).state:set("storeIndex", storeIndex, true)
            if Entity(ped).state["ff_shoprobbery:registerPed"] and Entity(ped).state.storeIndex == storeIndex then
                success = true
                break
            end
            Wait(100)
        end
        if success then
            table.insert(peds.created, netId)
            print(string.format("[DEBUG] Ped created for store %d (netId: %d, model: %s)", storeIndex, netId, modelHash))
        else
            print(string.format("[DEBUG] Failed to set state for ped for store %d (netId: %d)", storeIndex, netId))
            DeleteEntity(ped)
        end
    else
        print(string.format("[DEBUG] Failed to create ped for store %d: invalid netId", storeIndex))
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end

--- Returns the closest ped to the provided coords
---@param position vector3
---@return number | nil, number | nil
function peds.getClosest(position)
    local closestNet, closestDist = nil, nil

    for i = 1, #peds.created do
        local entity = NetworkGetEntityFromNetworkId(peds.created[i])
        if entity and DoesEntityExist(entity) then
            local entityCoords = GetEntityCoords(entity, false)
            local dx = entityCoords.x - position.x
            local dy = entityCoords.y - position.y
            local dz = entityCoords.z - position.z
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
            if not closestDist or dist < closestDist then
                closestNet = peds.created[i]
                closestDist = dist
            end
        end
    end

    return closestNet, closestDist
end

--- Delete shop peds
function peds.deleteAll()
    for i = 1, #peds.created do
        local netId = peds.created[i]
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    table.wipe(peds.created)
end

return peds