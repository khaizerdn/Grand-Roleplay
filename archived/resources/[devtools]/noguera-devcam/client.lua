local isCameraDebug = false
local debugCam = nil
local currentFOV = 25.0
local cameraSpeed = 0.01

-- Camera debug controls function
local function cameraDebugControls()
    if not isCameraDebug or not debugCam then return end
    
    CreateThread(function()
        DisableAllControlActions(0)
        
        local enabledControls = {
            32, 33, 34, 35, 44, 38,  -- Movement
            16, 17,                  -- FOV
            21, 23,                 -- Speed
            199,                    -- Print coords
            1, 2,                   -- Mouse
            245                     -- Chat
        }
        for _, control in ipairs(enabledControls) do
            EnableControlAction(0, control, true)
        end
        
        while isCameraDebug and debugCam do
            SetTextFont(0)
            SetTextScale(0.2, 0.2)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            
            local yPos = 0.05
            local lines = {
                "Camera Debug Controls:",
                "[W/S] Forward/Backward",
                "[A/D] Left/Right",
                "[Q/E] Up/Down",
                "[Mouse] Rotate",
                "[Shift/Ctrl] FOV +/- 0.5 (Current: " .. string.format("%.1f", currentFOV) .. ")",
                "[=/-] Speed +/- 0.05 (Current: " .. string.format("%.2f", cameraSpeed) .. ")",
                "[P] Print Coordinates",
                "[/devcam] Toggle Off",
                "[/setcam x y z rx ry rz fov] Set Position"
            }
            for _, line in ipairs(lines) do
                BeginTextCommandDisplayText("STRING")
                AddTextComponentString(line)
                EndTextCommandDisplayText(0.75, yPos)
                yPos = yPos + 0.02
            end
            
            -- Movement controls (unchanged)
            if IsDisabledControlPressed(0, 32) then
                local coords = GetCamCoord(debugCam)
                local rot = GetCamRot(debugCam, 2)
                local direction = vector3FromRotation(rot)
                SetCamCoord(debugCam, coords.x + direction.x * cameraSpeed, coords.y + direction.y * cameraSpeed, coords.z + direction.z * cameraSpeed)
            end
            if IsDisabledControlPressed(0, 33) then
                local coords = GetCamCoord(debugCam)
                local rot = GetCamRot(debugCam, 2)
                local direction = vector3FromRotation(rot)
                SetCamCoord(debugCam, coords.x - direction.x * cameraSpeed, coords.y - direction.y * cameraSpeed, coords.z - direction.z * cameraSpeed)
            end
            if IsDisabledControlPressed(0, 34) then
                local coords = GetCamCoord(debugCam)
                SetCamCoord(debugCam, coords.x, coords.y + cameraSpeed, coords.z)
            end
            if IsDisabledControlPressed(0, 35) then
                local coords = GetCamCoord(debugCam)
                SetCamCoord(debugCam, coords.x, coords.y - cameraSpeed, coords.z)
            end
            if IsDisabledControlPressed(0, 44) then
                local coords = GetCamCoord(debugCam)
                SetCamCoord(debugCam, coords.x, coords.y, coords.z + cameraSpeed)
            end
            if IsDisabledControlPressed(0, 38) then
                local coords = GetCamCoord(debugCam)
                SetCamCoord(debugCam, coords.x, coords.y, coords.z - cameraSpeed)
            end

            -- Mouse rotation (unchanged)
            local mouseX = GetControlNormal(0, 1) * 5.0
            local mouseY = GetControlNormal(0, 2) * 5.0
            if mouseX ~= 0.0 or mouseY ~= 0.0 then
                local rot = GetCamRot(debugCam, 2)
                local newX = rot.x - mouseY
                local newZ = rot.z - mouseX
                
                if newX > 89.0 then newX = 89.0 end
                if newX < -89.0 then newX = -89.0 end
                
                SetCamRot(debugCam, newX, 0.0, newZ, 2)
            end

            -- FOV and Speed controls (unchanged)
            if IsDisabledControlPressed(0, 16) then
                currentFOV = currentFOV + 0.5
                SetCamFov(debugCam, currentFOV)
            end
            if IsDisabledControlPressed(0, 17) then
                currentFOV = currentFOV - 0.5
                SetCamFov(debugCam, currentFOV)
            end
            if IsControlJustPressed(0, 21) then
                cameraSpeed = cameraSpeed + 0.05
            end
            if IsControlJustPressed(0, 23) then
                cameraSpeed = cameraSpeed - 0.05
            end

            -- Print coordinates (unchanged)
            if IsDisabledControlJustPressed(0, 199) then
                local coords = GetCamCoord(debugCam)
                local rot = GetCamRot(debugCam, 2)
                print(string.format("Coords: vector4(%.4f, %.4f, %.4f, %.4f)", coords.x, coords.y, coords.z, rot.z))
                print(string.format("Rotation: vector3(%.6f, %.6f, %.4f)", rot.x, rot.y, rot.z))
                print(string.format("FOV: %.1f", currentFOV))
            end

            Wait(0)
        end
        
        EnableAllControlActions(0)
    end)
end

-- Helper function for rotation to direction
function vector3FromRotation(rotation)
    local radX = math.rad(rotation.x)
    local radZ = math.rad(rotation.z)
    
    local cosX = math.cos(radX)
    local sinX = math.sin(radX)
    local cosZ = math.cos(radZ)
    local sinZ = math.sin(radZ)
    
    return vector3(
        -sinZ * cosX,
        cosZ * cosX,
        sinX
    )
end

-- Toggle camera debug
RegisterCommand('devcam', function()
    if not isCameraDebug then
        TriggerServerEvent('noguera-devcam:checkAdmin')
    else
        SetCamActive(debugCam, false)
        DestroyCam(debugCam, true)
        RenderScriptCams(false, false, 0, true, true)
        debugCam = nil
        isCameraDebug = false
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DevCam]", "Camera Debug Mode: OFF"}
        })
    end
end, false)

-- New command to set camera position, rotation, and FOV
RegisterCommand('setcam', function(source, args)
    if not isCameraDebug or not debugCam then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DevCam]", "Camera debug mode must be active. Use /devcam first."}
        })
        return
    end

    -- Check if all required parameters are provided
    if #args < 7 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DevCam]", "Usage: /setcam x y z rx ry rz fov"}
        })
        return
    end

    -- Parse arguments to numbers
    local x = tonumber(args[1])
    local y = tonumber(args[2])
    local z = tonumber(args[3])
    local rx = tonumber(args[4])
    local ry = tonumber(args[5])
    local rz = tonumber(args[6])
    local fov = tonumber(args[7])

    -- Validate inputs
    if not x or not y or not z or not rx or not ry or not rz or not fov then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DevCam]", "All parameters must be valid numbers"}
        })
        return
    end

    -- Clamp rotation X to prevent camera flipping
    if rx > 89.0 then rx = 89.0 end
    if rx < -89.0 then rx = -89.0 end

    -- Apply new camera settings
    SetCamCoord(debugCam, x, y, z)
    SetCamRot(debugCam, rx, ry, rz, 2)
    SetCamFov(debugCam, fov)
    currentFOV = fov

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"[DevCam]", string.format("Camera set to: Pos(%.2f, %.2f, %.2f) Rot(%.2f, %.2f, %.2f) FOV(%.1f)", x, y, z, rx, ry, rz, fov)}
    })
end, false)

-- Handle admin check response
RegisterNetEvent('noguera-devcam:adminResponse')
AddEventHandler('noguera-devcam:adminResponse', function(isAdmin)
    if isAdmin then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)
        
        debugCam = CreateCamWithParams(
            'DEFAULT_SCRIPTED_CAMERA',
            coords.x, coords.y, coords.z + 1.0,
            0.0, 0.0, heading,
            currentFOV,
            false,
            2
        )
        
        SetCamActive(debugCam, true)
        RenderScriptCams(true, false, 0, true, true)
        SetNuiFocus(false, false)
        isCameraDebug = true
        
        cameraDebugControls()
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[DevCam]", "Camera Debug Mode: ON - Use mouse to rotate, controls to adjust"}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Error]", "You don't have permission to use /devcam"}
        })
    end
end)

-- Chat suggestions
TriggerEvent('chat:addSuggestion', '/devcam', 'Toggle developer camera (admin only)')
TriggerEvent('chat:addSuggestion', '/setcam', 'Set camera position (x y z rx ry rz fov)', {
    { name = "x", help = "X coordinate" },
    { name = "y", help = "Y coordinate" },
    { name = "z", help = "Z coordinate" },
    { name = "rx", help = "X rotation" },
    { name = "ry", help = "Y rotation" },
    { name = "rz", help = "Z rotation" },
    { name = "fov", help = "Field of View" }
})

-- Resource start notification
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("Noguera Dev Camera loaded. Use /devcam to toggle and /setcam to set position (admin only)")
end)