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
                                if storeData and not storeData.active and storeData.cooldown == -1 then
                                    local clerkPos = GetEntityCoords(entity, false)
                                    local till = GetClosestObjectOfType(clerkPos.x, clerkPos.y, clerkPos.z, 5.0, `prop_till_01`, false, false, false)
                                    if till and DoesEntityExist(till) then
                                        local tillCoords = GetOffsetFromEntityInWorldCoords(till, 0.0, 0.0, -0.12)
                                        local tillRotation = GetEntityRotation(till, 2)
                                        TriggerServerEvent("ff_shoprobbery:server:startedRobbery", tillCoords, tillRotation)
                                        Wait(5000)
                                    end
                                end
                            end
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

RegisterNetEvent("ff_shoprobbery:client:cancelRobbery", function()
    -- Clear any active progress bars or tasks only if a progress bar is active
    if Config.Progress == "ox_lib_bar" or Config.Progress == "ox_lib_circle" then
        if lib.progressActive() then
            lib.cancelProgress()
        end
    end
end)