lib.locale()

local safe = require "client.safe"
local network = require "client.network"
require "client.peds"
require "client.tills"

---@return boolean
---@return integer
local function getPedInFront()
    local pedCoords = GetEntityCoords(cache.ped, false)
    local rayEnd = pedCoords + (GetEntityForwardVector(cache.ped) * 5.0)
    local shapeTest = StartShapeTestCapsule(pedCoords.x, pedCoords.y, pedCoords.z, rayEnd.x, rayEnd.y, rayEnd.z, 1.0, 4, cache.ped, 7)
    local _, hit, _, _, entity = GetShapeTestResult(shapeTest)
    return hit, entity
end

--- Handle starting robbery by aiming at clerk
--- Handle starting robbery by aiming at clerk
local function startClerkTask()
    CreateThread(function()
        local sleep = 1000
        while true do
            local weapon = cache.weapon
            if weapon and weapon ~= `WEAPON_UNARMED` then
                sleep = 5
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
                                        -- Normal robbery
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
                                        -- Non-robbable behavior: trigger hands-up and flee
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

startClerkTask()

-- Deleting all targets on resource stop/restart
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
end)

--- Used for recreating the aim at clerk task when cooldown is over
RegisterNetEvent("ff_shoprobbery:client:reset", startClerkTask)

--- Disable a networks target
---@param index number
RegisterNetEvent("ff_shoprobbery:client:disableNetwork", function(index)
    if not index or type(index) ~= "number" then return end
end)

-- Handle statebag updates for each store
for i = 1, #Config.Locations do
    AddStateBagChangeHandler(string.format("ff_shoprobbery:store:%s", i), "", function(bagName, key, value, reserved, replicated)
        Debug("Store data updated for store " .. i .. ": " .. json.encode(value, { indent = true }), DebugTypes.Info)
        if value and value.robbedTill and not value.hackedNetwork then
            Wait(100) -- Ensure state sync
            Debug("Triggering network interaction for store " .. i, DebugTypes.Info)
            network.createInteract(i)
        elseif value and value.hackedNetwork and not value.openedSafe then
            Wait(100) -- Ensure state sync
            Debug("Triggering safe interaction for store " .. i, DebugTypes.Info)
            safe.createInteract(i, value.safeNet)
        end
    end)
end

--- Create the safe at the specified position
---@param safePosition vector4
---@return boolean, number?
lib.callback.register('ff_shoprobbery:createSafe', function(safePosition)
    return safe.create(safePosition)
end)

lib.callback.register('ff_shoprobbery:isPedDead', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity and DoesEntityExist(entity) then
        return IsEntityDead(entity)
    end
    return false -- Return false if entity doesn’t exist
end)

-- Initialize proximity tracking for each store
local playerProximity = {}
for index, _ in ipairs(Config.Locations) do
    playerProximity[index] = false
end

-- Thread to monitor player proximity to stores
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
        Wait(1000) -- Check every second to reduce resource usage
    end
end)