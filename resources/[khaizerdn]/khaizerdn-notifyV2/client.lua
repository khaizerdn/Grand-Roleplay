local QBCore = exports['qb-core']:GetCoreObject()

-- Register NUI callback
RegisterNUICallback('hideNotification', function(data, cb)
    print('[khaizerdn-notifyV2] NUI callback: hideNotification')
    cb({})
end)

-- Show Basic Notification
RegisterNetEvent('khaizerdn-notifyV2:ShowNotification')
AddEventHandler('khaizerdn-notifyV2:ShowNotification', function(message, duration)
    print('[khaizerdn-notifyV2] Triggering basic notification:', message)
    SendNUIMessage({
        type = 'basic',
        message = message,
        duration = duration or 3000
    })
end)

-- Show Advanced Notification
RegisterNetEvent('khaizerdn-notifyV2:ShowAdvancedNotification')
AddEventHandler('khaizerdn-notifyV2:ShowAdvancedNotification', function(title, subtitle, message, image, duration)
    print('[khaizerdn-notifyV2] Triggering advanced notification:', title, subtitle, message)
    SendNUIMessage({
        type = 'advanced',
        title = title,
        subtitle = subtitle,
        message = message,
        image = image or 'https://via.placeholder.com/50',
        duration = duration or 5000
    })
end)

-- Show Help Notification
RegisterNetEvent('khaizerdn-notifyV2:ShowHelpNotification')
AddEventHandler('khaizerdn-notifyV2:ShowHelpNotification', function(message, duration)
    print('[khaizerdn-notifyV2] Triggering help notification:', message)
    SendNUIMessage({
        type = 'help',
        message = message,
        duration = duration or 5000
    })
end)

-- Clear Help Notification
RegisterNetEvent('khaizerdn-notifyV2:ClearHelpNotification')
AddEventHandler('khaizerdn-notifyV2:ClearHelpNotification', function()
    print('[khaizerdn-notifyV2] Clearing help notification')
    SendNUIMessage({
        type = 'clear_help'
    })
end)

-- Client-side exports
exports('ShowNotification', function(message, duration)
    TriggerEvent('khaizerdn-notifyV2:ShowNotification', message, duration)
end)

exports('ShowAdvancedNotification', function(title, subtitle, message, image, duration)
    TriggerEvent('khaizerdn-notifyV2:ShowAdvancedNotification', title, subtitle, message, image, duration)
end)

exports('ShowHelpNotification', function(message, duration)
    TriggerEvent('khaizerdn-notifyV2:ShowHelpNotification', message, duration)
end)

exports('ClearHelpNotification', function()
    TriggerEvent('khaizerdn-notifyV2:ClearHelpNotification')
end)

-- Debug command to test notifications
RegisterCommand('testnotify', function(source, args)
    local type = args[1] or 'basic'
    print('[khaizerdn-notifyV2] Testing notification type:', type)
    if type == 'basic' then
        exports['khaizerdn-notifyV2']:ShowNotification('Test Basic Notification', 3000)
    elseif type == 'advanced' then
        exports['khaizerdn-notifyV2']:ShowAdvancedNotification('Test Title', 'Test Subtitle', 'Test Advanced Notification', 'https://via.placeholder.com/50', 5000)
    elseif type == 'help' then
        exports['khaizerdn-notifyV2']:ShowHelpNotification('Test Help Notification', 5000)
    elseif type == 'clear' then
        exports['khaizerdn-notifyV2']:ClearHelpNotification()
    end
end, false)