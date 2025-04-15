local QBCore = exports['qb-core']:GetCoreObject()

-- Configuration
local defaultAnimations = {
    "mp_character_creation@lineup@male_a intro",
    "mp_character_creation@lineup@male_a loop",
    "mp_character_creation@lineup@male_a react_light",
    "mp_character_creation@lineup@male_a high_to_low",
    "mp_character_creation@lineup@male_a outro",
    "mp_character_creation@lineup@male_b intro",
    "mp_character_creation@lineup@male_b loop",
    "mp_character_creation@lineup@male_b react_light",
    "mp_character_creation@lineup@male_b high_to_low",
    "mp_character_creation@lineup@male_b outro"
}

local cameraSettings = {
    x = 414.8155,
    y = -998.6686,
    z = -99.0535,
    rx = 1.338627,
    ry = 0.0,
    rz = 93.2906,
    fov = 27.5
}

local lastCoords = nil
local lastHeading = nil
local animationQueue = {}

-- Helper Functions
local function splitAnimString(animString)
    local dict, anim = animString:match("^(.-)%s+([^%s]+)$")
    return dict, anim
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
end

local function formatCoordsAndHeading(coords, heading)
    return string.format("%.4f %.4f %.4f %.4f", 
        coords.x, coords.y, coords.z, heading)
end

-- Animation Playback
local function playAnimation(dict, anim, duration, useCamera, isSequential, startOffset)
    local playerPed = PlayerPedId()
    
    if not lastCoords then
        lastCoords = GetEntityCoords(playerPed)
        lastHeading = GetEntityHeading(playerPed)
    end
    
    loadAnimDict(dict)
    
    local cam
    if useCamera then
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 
            cameraSettings.x, cameraSettings.y, cameraSettings.z,
            cameraSettings.rx, cameraSettings.ry, cameraSettings.rz,
            cameraSettings.fov, true, 2)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, false)
    end

    local animDuration = duration or (GetAnimDuration(dict, anim) * 1000)
    if animDuration <= 0 then animDuration = 5000 end
    
    -- Apply startOffset (0.0 to 1.0) if provided, default to 0.0
    local offset = startOffset or 0.0
    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, duration or -1, 0, offset, false, false, false)
    
    local isPlaying = true
    
    Citizen.CreateThread(function()
        while isPlaying do
            if IsControlJustPressed(0, 73) then -- X key
                isPlaying = false
                ClearPedTasksImmediately(playerPed)
                if cam then
                    SetCamActive(cam, false)
                    RenderScriptCams(false, true, 500, true, false)
                    DestroyCam(cam, false)
                end
                QBCore.Functions.Notify('Animation canceled', 'error')
            elseif IsControlJustPressed(0, 58) then -- G key
                if lastCoords and lastHeading then
                    isPlaying = false
                    ClearPedTasksImmediately(playerPed)
                    if cam then
                        SetCamActive(cam, false)
                        RenderScriptCams(false, true, 500, true, false)
                        DestroyCam(cam, false)
                    end
                    SetEntityCoordsNoOffset(playerPed, lastCoords.x, lastCoords.y, lastCoords.z, false, false, false)
                    SetEntityHeading(playerPed, lastHeading)
                    Wait(100)
                    SetGameplayCamRelativeHeading(0.0)
                    QBCore.Functions.Notify('Teleported to starting position', 'success')
                end
            end
            Wait(0)
        end
    end)

    if animDuration > 0 then
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < animDuration and isPlaying do
            Wait(0)
        end
        if isPlaying and not isSequential then
            ClearPedTasksImmediately(playerPed)
            if cam then
                SetCamActive(cam, false)
                RenderScriptCams(false, true, 500, true, false)
                DestroyCam(cam, false)
            end
            RemoveAnimDict(dict)
        end
    end
    return isPlaying
end

local function playAnimationQueue()
    local playerPed = PlayerPedId()
    lastCoords = GetEntityCoords(playerPed)
    lastHeading = GetEntityHeading(playerPed)
    
    for _, animString in ipairs(animationQueue) do
        loadAnimDict(splitAnimString(animString))
    end

    local isPlaying = true
    for _, animString in ipairs(animationQueue) do
        if not isPlaying then break end
        local dict, anim = splitAnimString(animString)
        isPlaying = playAnimation(dict, anim, nil, false, true)
    end
    
    if isPlaying then
        ClearPedTasksImmediately(playerPed)
        for _, animString in ipairs(animationQueue) do
            RemoveAnimDict(splitAnimString(animString))
        end
        QBCore.Functions.Notify('Animation sequence completed', 'success')
    end
    
    animationQueue = {}
end

-- Menu System
local function openAnimationMenu()
    exports['qb-menu']:openMenu({
        { header = "Animation Menu", isMenuHeader = true },
        { header = "Play Single Animation", txt = "Play an animation immediately", params = { event = "animation:selectSingleAnimation" } },
        { header = "Add Animation", txt = "Add an animation to the queue", params = { event = "animation:selectAnimation" } },
        { header = "View Queue", txt = "See current animation queue", params = { event = "animation:viewQueue" } },
        { header = "Play Queue", txt = "Play all queued animations", params = { event = "animation:playQueue" } },
        { header = "Clear Queue", txt = "Remove all animations from queue", params = { event = "animation:clearQueue" } },
        { header = "Close", txt = "", params = { event = "qb-menu:client:closeMenu" } }
    })
end

RegisterNetEvent('animation:selectSingleAnimation', function()
    local animMenu = {{ header = "Select Animation to Play", isMenuHeader = true }}
    for i, animString in ipairs(defaultAnimations) do
        local dict, anim = splitAnimString(animString)
        table.insert(animMenu, {
            header = anim,
            txt = "Dict: " .. dict,
            params = { event = "animation:selectStartOffset", args = { index = i } }
        })
    end
    table.insert(animMenu, { header = "Back", params = { event = "animation:openMainMenu" } })
    exports['qb-menu']:openMenu(animMenu)
end)

RegisterNetEvent('animation:selectStartOffset', function(data)
    local animString = defaultAnimations[data.index]
    local _, anim = splitAnimString(animString)
    exports['qb-menu']:openMenu({
        { header = "Start Offset for " .. anim, isMenuHeader = true },
        { header = "Start (0%)", txt = "Begin at the start", params = { event = "animation:playSingle", args = { index = data.index, offset = 0.0 } } },
        { header = "25%", txt = "Begin at 25%", params = { event = "animation:playSingle", args = { index = data.index, offset = 0.25 } } },
        { header = "50%", txt = "Begin at 50%", params = { event = "animation:playSingle", args = { index = data.index, offset = 0.5 } } },
        { header = "75%", txt = "Begin at 75%", params = { event = "animation:playSingle", args = { index = data.index, offset = 0.75 } } },
        { header = "End (100%)", txt = "Begin at the end", params = { event = "animation:playSingle", args = { index = data.index, offset = 1.0 } } },
        { header = "Back", params = { event = "animation:selectSingleAnimation" } }
    })
end)

RegisterNetEvent('animation:playSingle', function(data)
    local animString = defaultAnimations[data.index]
    local dict, anim = splitAnimString(animString)
    local offset = data.offset or 0.0
    playAnimation(dict, anim, nil, false, false, offset)
    QBCore.Functions.Notify('Playing animation: ' .. anim .. ' from ' .. (offset * 100) .. '%', 'success')
end)

RegisterNetEvent('animation:selectAnimation', function()
    local animMenu = {{ header = "Select Animation", isMenuHeader = true }}
    for i, animString in ipairs(defaultAnimations) do
        local dict, anim = splitAnimString(animString)
        table.insert(animMenu, {
            header = anim,
            txt = "Dict: " .. dict,
            params = { event = "animation:addToQueue", args = { index = i } }
        })
    end
    table.insert(animMenu, { header = "Back", params = { event = "animation:openMainMenu" } })
    exports['qb-menu']:openMenu(animMenu)
end)

RegisterNetEvent('animation:addToQueue', function(data)
    local animString = defaultAnimations[data.index]
    local _, anim = splitAnimString(animString)
    table.insert(animationQueue, animString)
    QBCore.Functions.Notify('Added ' .. anim .. ' to queue', 'success')
    TriggerEvent('animation:openMainMenu')
end)

RegisterNetEvent('animation:viewQueue', function()
    local queueMenu = {{ header = "Animation Queue", isMenuHeader = true }}
    if #animationQueue == 0 then
        table.insert(queueMenu, { header = "Queue is empty", disabled = true })
    else
        for i, animString in ipairs(animationQueue) do
            local dict, anim = splitAnimString(animString)
            table.insert(queueMenu, { header = i .. ". " .. anim, txt = "Dict: " .. dict })
        end
    end
    table.insert(queueMenu, { header = "Back", params = { event = "animation:openMainMenu" } })
    exports['qb-menu']:openMenu(queueMenu)
end)

RegisterNetEvent('animation:playQueue', function()
    if #animationQueue == 0 then
        QBCore.Functions.Notify('Animation queue is empty', 'error')
        return
    end
    playAnimationQueue()
end)

RegisterNetEvent('animation:clearQueue', function()
    animationQueue = {}
    QBCore.Functions.Notify('Animation queue cleared', 'success')
    TriggerEvent('animation:openMainMenu')
end)

RegisterNetEvent('animation:openMainMenu', openAnimationMenu)

-- Commands
RegisterCommand('testanim', function()
    local playerPed = PlayerPedId()
    lastCoords = GetEntityCoords(playerPed)
    lastHeading = GetEntityHeading(playerPed)
    
    print(formatCoordsAndHeading(lastCoords, lastHeading))
    
    for _, animString in ipairs(defaultAnimations) do
        loadAnimDict(splitAnimString(animString))
    end

    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 
        cameraSettings.x, cameraSettings.y, cameraSettings.z,
        cameraSettings.rx, cameraSettings.ry, cameraSettings.rz,
        cameraSettings.fov, true, 2)
    
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, false)
    
    local isPlaying = true
    
    Citizen.CreateThread(function()
        while isPlaying do
            if IsControlJustPressed(0, 73) then
                isPlaying = false
                ClearPedTasksImmediately(playerPed)
                SetCamActive(cam, false)
                RenderScriptCams(false, true, 500, true, false)
                DestroyCam(cam, false)
                QBCore.Functions.Notify('Animation test canceled', 'error')
            elseif IsControlJustPressed(0, 58) then
                if lastCoords and lastHeading then
                    isPlaying = false
                    ClearPedTasksImmediately(playerPed)
                    SetCamActive(cam, false)
                    RenderScriptCams(false, true, 500, true, false)
                    DestroyCam(cam, false)
                    SetEntityCoordsNoOffset(playerPed, lastCoords.x, lastCoords.y, lastCoords.z, false, false, false)
                    SetEntityHeading(playerPed, lastHeading)
                    Wait(100)
                    SetGameplayCamRelativeHeading(0.0)
                    QBCore.Functions.Notify('Teleported to starting position', 'success')
                end
            end
            Wait(0)
        end
    end)

    for _, animString in ipairs(defaultAnimations) do
        if not isPlaying then break end
        local dict, anim = splitAnimString(animString)
        TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
        local animLength = math.max(GetAnimDuration(dict, anim) * 1000, 5000)
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < animLength and isPlaying do
            Wait(0)
        end
    end

    if isPlaying then
        ClearPedTasksImmediately(playerPed)
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(cam, false)
        QBCore.Functions.Notify('Animation test completed', 'success')
    end
end, false)

RegisterCommand('anim', function(source, args, rawCommand)
    if #args < 2 then
        QBCore.Functions.Notify('Usage: /anim [dictionary] [animation] [duration (optional, use -1 for full duration)]', 'error')
        return
    end
    
    local dict, anim, duration = args[1], args[2], args[3] and tonumber(args[3])
    playAnimation(dict, anim, duration, false, false)
    QBCore.Functions.Notify('Playing animation: ' .. anim .. (duration == -1 and ' (full duration)' or ''), 'success')
end, false)

RegisterCommand('animmenu', openAnimationMenu, false)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local playerPed = PlayerPedId()
        ClearPedTasksImmediately(playerPed)
        RenderScriptCams(false, false, 0, true, false)
        for _, animString in ipairs(defaultAnimations) do
            RemoveAnimDict(splitAnimString(animString))
        end
    end
end)

-- Chat Suggestions
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/testanim', 'Test animations with camera (X to cancel, G to teleport)')
    TriggerEvent('chat:addSuggestion', '/anim', 'Play specific animation (X to cancel, G to teleport)', {
        { name = "dictionary", help = "Animation dictionary" },
        { name = "animation", help = "Animation name" },
        { name = "duration", help = "Optional duration in ms (-1 for full)" }
    })
    TriggerEvent('chat:addSuggestion', '/animmenu', 'Open animation queue menu')
end)
