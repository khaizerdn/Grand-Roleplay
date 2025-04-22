-- Show Advanced Notification
RegisterNetEvent('khaizerdn-notify:ShowAdvancedNotification')
AddEventHandler('khaizerdn-notify:ShowAdvancedNotification', function(title, subtitle, message, icon, iconType, duration, position)
    if position and (position == 'topRight' or position == 'topLeft' or position == 'bottomRight' or position == 'bottomLeft') then
        local text = title .. '~n~' .. subtitle .. '~n~' .. message
        TriggerEvent('khaizerdn-notify:CustomNotification', text, position, duration or 5000, 'advanced')
    else
        BeginTextCommandThefeedPost('TWOSTRINGS')
        AddTextComponentSubstringPlayerName(title .. '~n~' .. subtitle)
        AddTextComponentSubstringPlayerName(message)
        if icon then
            EndTextCommandThefeedPostMessagetext(icon, icon, false, iconType or 1, title, subtitle)
        else
            EndTextCommandThefeedPostMessagetext('CHAR_DEFAULT', 'CHAR_DEFAULT', false, 1, title, subtitle)
        end
        EndTextCommandThefeedPostTicker(true, false)
        
        PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
        
        local timer = duration or 5000
        Citizen.Wait(timer)
        ThefeedRemoveItem()
    end
end)

-- Show Help Notification
RegisterNetEvent('khaizerdn-notify:ShowHelpNotification')
AddEventHandler('khaizerdn-notify:ShowHelpNotification', function(message, duration)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end)

-- Clear Help Notification
RegisterNetEvent('khaizerdn-notify:ClearHelpNotification')
AddEventHandler('khaizerdn-notify:ClearHelpNotification', function()
    ClearAllHelpMessages()
end)

-- Show Basic Notification
RegisterNetEvent('khaizerdn-notify:ShowNotification')
AddEventHandler('khaizerdn-notify:ShowNotification', function(message, duration, position)
    if position and (position == 'topRight' or position == 'topLeft' or position == 'bottomRight' or position == 'bottomLeft') then
        TriggerEvent('khaizerdn-notify:CustomNotification', message, position, duration or 3000, 'basic')
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(true, false)
        
        PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
        
        local timer = duration or 3000
        Citizen.Wait(timer)
        ThefeedRemoveItem()
    end
end)

-- Custom Notification (based on notif.lua)
local body = {
    scale = 0.3,
    offsetLine = 0.02,
    offsetX = 0.005,
    offsetY = 0.004,
    dict = 'commonmenu',
    sprite = 'gradient_bgd',
    width = 0.14,
    height = 0.012,
    heading = -90.0,
    gap = 0.002,
}

local defaultText = '~r~~h~ERROR : ~h~~s~The text of the notification is nil.'
local defaultType = 'topRight'
local defaultTimeout = 6000

RequestStreamedTextureDict(body.dict)

local function goDown(v, id)
    for i = 1, #v do
        if v[i].draw and i ~= id then
            v[i].y = v[i].y + (body.height + (v[id].lines*2 + 1)*body.offsetLine)/2 + body.gap
        end
    end
end

local function goUp(v, id)
    for i = 1, #v do
        if v[i].draw and i ~= id then
            v[i].y = v[i].y - (body.height + (v[id].lines*2 + 1)*body.offsetLine)/2 - body.gap
        end
    end
end

local function CountLines(v, text)
    BeginTextCommandLineCount("STRING")
    SetTextScale(body.scale, body.scale)
    SetTextWrap(v.x, v.x + body.width - body.offsetX)
    AddTextComponentSubstringPlayerName(text)
    return GetTextScreenLineCount(v.x + body.offsetX, v.y + body.offsetY)
end

local function DrawText(v, text)
    SetTextScale(body.scale, body.scale)
    SetTextWrap(v.x, v.x + body.width - body.offsetX)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(v.x + body.offsetX, v.y + body.offsetY)
end

local function DrawBackground(v)
    DrawSprite(body.dict, body.sprite, v.x + body.width/2, v.y + (body.height + v.lines*body.offsetLine)/2, body.width, body.height + v.lines*body.offsetLine, body.heading, 255, 255, 255, 255)
end

local positions = {
    ['topRight'] = { x = 0.85, y = 0.015, notif = {}, offset = goDown },
    ['topLeft'] = { x = 0.01, y = 0.015, notif = {}, offset = goDown },
    ['bottomRight'] = { x = 0.85, y = 0.955, notif = {}, offset = goUp },
    ['bottomLeft'] = { x = 0.015, y = 0.75, notif = {}, offset = goUp },
}

RegisterNetEvent('khaizerdn-notify:CustomNotification')
AddEventHandler('khaizerdn-notify:CustomNotification', function(text, type, timeout, notifType)
    text = text or defaultText
    type = type or defaultType
    timeout = timeout or defaultTimeout
    notifType = notifType or 'basic'

    local p = positions[type]
    local id = #p.notif + 1
    local nbrLines = CountLines(p, text)

    p.notif[id] = {
        x = p.x,
        y = p.y,
        lines = nbrLines,
        draw = true,
    }

    if id > 1 then
        p.offset(p.notif, id)
    end

    -- Play sound based on notification type
    if notifType == 'advanced' then
        PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
    else
        PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
    end

    Citizen.CreateThread(function()
        Wait(timeout)
        p.notif[id].draw = false
    end)

    Citizen.CreateThread(function()
        while p.notif[id].draw do
            Wait(0)
            DrawBackground(p.notif[id])
            DrawText(p.notif[id], text)
        end
    end)
end)

-- Client-side exports
exports('ShowNotification', function(message, duration, position)
    TriggerEvent('khaizerdn-notify:ShowNotification', message, duration, position)
end)

exports('ShowAdvancedNotification', function(title, subtitle, message, icon, iconType, duration, position)
    TriggerEvent('khaizerdn-notify:ShowAdvancedNotification', title, subtitle, message, icon, iconType, duration, position)
end)

exports('ShowHelpNotification', function(message, duration)
    TriggerEvent('khaizerdn-notify:ShowHelpNotification', message, duration)
end)

exports('ClearHelpNotification', function()
    TriggerEvent('khaizerdn-notify:ClearHelpNotification')
end)