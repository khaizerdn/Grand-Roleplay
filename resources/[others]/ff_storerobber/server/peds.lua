local peds = {
    created = {}
}

--- Create shop peds on server start
---@param location vector4
---@param pedPool string|nil
function peds.create(location, pedPool)
    -- Default to "general" pool if pedPool is nil
    pedPool = pedPool or "general"
    
    -- Check if the specified ped pool exists
    if not Config.PedPools[pedPool] then
        print("Error: Ped pool '" .. pedPool .. "' does not exist in Config.PedPools.")
        return
    end
    
    -- Select a random ped from the specified pool
    local pedModels = Config.PedPools[pedPool]
    local modelHash = pedModels[math.random(1, #pedModels)]
    local ped = CreatePed(4, modelHash, location.x, location.y, location.z, location.w, true, false)
    local netId = NetworkGetNetworkIdFromEntity(ped)

    if netId and netId > 0 then
        Entity(ped).state:set("ff_shoprobbery:registerPed", true, true)
        table.insert(peds.created, netId)
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
            local dist = #(GetEntityCoords(entity, false) - position)
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