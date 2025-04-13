-- client.lua
-- FiveM QB-Core Entity Info Display Script

-- Configuration
local displayDistance = 10.0 -- Maximum distance to detect entities (in meters)
local textScale = 0.4 -- Size of the text
local checkInterval = 100 -- How often to check (in milliseconds)
local textX = 0.85 -- X position (top-right)
local textY = 0.05 -- Y position (top-right)
local debugMode = true -- Set to true to visualize raycast box (for testing)
local boxColor = {r = 255, g = 0, b = 0, a = 255} -- Red box by default

-- Cache for optimization
local QBCore = exports['qb-core']:GetCoreObject()
local playerPed = nil
local currentEntity = nil
local currentHash = nil
local currentName = nil
local isAiming = false

-- Main thread to check aiming and update entity info
Citizen.CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        
        -- Check aiming state
        isAiming = IsPedArmed(playerPed, 4) and IsPlayerFreeAiming(PlayerId())
        
        if isAiming then
            local entity, entityHash, entityName = GetAimedEntity()
            
            if entity and entityHash and entityName then
                currentEntity = entity
                currentHash = entityHash
                currentName = entityName
            else
                -- Fallback for interiors like mugshot room
                entity, entityHash, entityName = GetEntityInFrontOfCamera()
                if entity and entityHash and entityName then
                    currentEntity = entity
                    currentHash = entityHash
                    currentName = entityName
                else
                    currentEntity = nil
                    currentHash = nil
                    currentName = nil
                end
            end
        else
            currentEntity = nil
            currentHash = nil
            currentName = nil
        end
        
        Citizen.Wait(checkInterval)
    end
end)

-- Thread to handle text display and debug visualization
Citizen.CreateThread(function()
    while true do
        if currentEntity then
            DrawEntityInfo()
            if debugMode then
                DrawDebugBox(currentEntity)
            end
        end
        
        Citizen.Wait(0)
    end
end)

-- Function to get the entity player is aiming at
function GetAimedEntity()
    -- First try the native free-aiming detection
    local success, entityHit = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if success and entityHit and DoesEntityExist(entityHit) and entityHit ~= 0 then
        local entityType = GetEntityType(entityHit)
        if entityType > 0 then
            local success, entityHash = pcall(GetEntityModel, entityHit)
            if success and entityHash then
                local entityName = GetEntityName(entityHit, entityType, entityHash)
                if entityName then
                    return entityHit, entityHash, entityName
                end
            end
        end
        return nil, nil, nil
    end

    -- Fallback to raycasting
    local camCoord = GetGameplayCamCoord()
    local direction = GetDirectionFromCam()
    local destination = {
        x = camCoord.x + direction.x * displayDistance,
        y = camCoord.y + direction.y * displayDistance,
        z = camCoord.z + direction.z * displayDistance
    }
    
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        camCoord.x, camCoord.y, camCoord.z,
        destination.x, destination.y, destination.z,
        -1, playerPed, 0
    )
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
    
    if hit and entityHit and DoesEntityExist(entityHit) and entityHit ~= 0 then
        local entityType = GetEntityType(entityHit)
        if entityType > 0 then
            local success, entityHash = pcall(GetEntityModel, entityHit)
            if success and entityHash then
                local entityName = GetEntityName(entityHit, entityType, entityHash)
                if entityName then
                    return entityHit, entityHash, entityName
                end
            end
        end
    end
    
    return nil, nil, nil
end

-- Fallback function for detecting entities in front of camera
function GetEntityInFrontOfCamera()
    local camCoord = GetGameplayCamCoord()
    local direction = GetDirectionFromCam()
    local destination = {
        x = camCoord.x + direction.x * displayDistance,
        y = camCoord.y + direction.y * displayDistance,
        z = camCoord.z + direction.z * displayDistance
    }
    
    -- Use a broader shape test to catch static objects
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        camCoord.x, camCoord.y, camCoord.z,
        destination.x, destination.y, destination.z,
        7, -- 1 = peds, 2 = vehicles, 4 = objects (7 = all)
        playerPed, 0
    )
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
    
    if hit and entityHit and DoesEntityExist(entityHit) and entityHit ~= 0 then
        local entityType = GetEntityType(entityHit)
        if entityType > 0 then
            local success, entityHash = pcall(GetEntityModel, entityHit)
            if success and entityHash then
                local entityName = GetEntityName(entityHit, entityType, entityHash)
                if entityName then
                    return entityHit, entityHash, entityName
                end
            end
        end
    end
    
    return nil, nil, nil
end

-- Function to determine entity name based on type and hash
function GetEntityName(entity, entityType, entityHash)
    if entityType == 1 then -- Ped
        return IsPedAPlayer(entity) and "Player" or "NPC"
    elseif entityType == 2 then -- Vehicle
        local displayName = GetLabelText(GetDisplayNameFromVehicleModel(entityHash))
        return displayName ~= "NULL" and displayName or "Vehicle"
    elseif entityType == 3 then -- Object
        return "Object"
    end
    return nil
end

-- Function to get direction vector from camera
function GetDirectionFromCam()
    local rot = GetGameplayCamRot(0)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosX = math.cos(rotX)
    local sinX = math.sin(rotX)
    local cosZ = math.cos(rotZ)
    local sinZ = math.sin(rotZ)
    
    return {
        x = -sinZ * cosX,
        y = cosZ * cosX,
        z = sinX
    }
end

-- Function to draw entity info in top-right corner
function DrawEntityInfo()
    SetTextScale(textScale, textScale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    
    -- Draw entity name
    SetTextEntry("STRING")
    AddTextComponentString("Entity: " .. currentName)
    DrawText(textX, textY)
    
    -- Draw entity hash below it
    SetTextEntry("STRING")
    AddTextComponentString("Hash: " .. currentHash)
    DrawText(textX, textY + 0.045)
end

-- Function to draw a box around the entity
function DrawDebugBox(entity)
    if not DoesEntityExist(entity) then return end
    
    -- Get entity bounding box
    local min, max = GetModelDimensions(GetEntityModel(entity))
    if not min or not max then return end
    
    local coords = GetEntityCoords(entity)
    local rotation = GetEntityRotation(entity, 2)
    
    -- Adjust coordinates to account for entity rotation
    local minX = coords.x + min.x
    local minY = coords.y + min.y
    local minZ = coords.z + min.z
    local maxX = coords.x + max.x
    local maxY = coords.y + max.y
    local maxZ = coords.z + max.z
    
    DrawBox(
        minX, minY, minZ, -- Minimum coordinates
        maxX, maxY, maxZ, -- Maximum coordinates
        boxColor.r, boxColor.g, boxColor.b, boxColor.a
    )
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        currentEntity = nil
        currentHash = nil
        currentName = nil
        isAiming = false
    end
end)