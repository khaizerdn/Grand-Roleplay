-- Notification exports
exports('ShowNotification', function(source, message, duration, position)
    TriggerClientEvent('khaizerdn-notify:ShowNotification', source, message, duration, position)
end)

exports('ShowAdvancedNotification', function(source, title, subtitle, message, icon, iconType, duration, position)
    TriggerClientEvent('khaizerdn-notify:ShowAdvancedNotification', source, title, subtitle, message, icon, iconType, duration, position)
end)

exports('ShowHelpNotification', function(source, message, duration)
    TriggerClientEvent('khaizerdn-notify:ShowHelpNotification', source, message, duration)
end)

exports('ClearHelpNotification', function(source)
    TriggerClientEvent('khaizerdn-notify:ClearHelpNotification', source)
end)

-- Test command
RegisterCommand('testnotify', function(source, args)
    local type = args[1] and args[1]:lower() or 'basic'
    local position = args[2] or nil
    
    if type == 'basic' then
        exports['khaizerdn-notify']:ShowNotification(source, "This is a basic notification!", 10000, 'topRight')
    elseif type == 'advanced' then
        exports['khaizerdn-notify']:ShowAdvancedNotification(source, "Test Title", "Test Subtitle", "This is an advanced notification!", "CHAR_SOCIAL_CLUB", 1, 10000, 'topRight')
    elseif type == 'help' then
        exports['khaizerdn-notify']:ShowHelpNotification(source, "This is a help notification! Press ~INPUT_CONTEXT~ to interact", 10000)
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Error', 'Invalid notification type. Use: basic, advanced, or help' } })
    end
end, false)