local QBCore = exports['qb-core']:GetCoreObject()

-- Notification exports
exports('ShowNotification', function(source, message, duration)
    TriggerClientEvent('khaizerdn-notify:ShowNotification', source, message, duration)
end)

exports('ShowAdvancedNotification', function(source, title, subtitle, message, icon, iconType, duration)
    TriggerClientEvent('khaizerdn-notify:ShowAdvancedNotification', source, title, subtitle, message, icon, iconType, duration)
end)

exports('ShowHelpNotification', function(source, message, duration)
    TriggerClientEvent('khaizerdn-notify:ShowHelpNotification', source, message, duration)
end)

-- Test command
-- QBCore.Commands.Add('testnotify', 'Test notification types (basic, advanced, help)', { { name = 'type', help = 'Notification type (basic, advanced, help)' } }, true, function(source, args)
--     local type = args[1] and args[1]:lower() or 'basic'
    
--     if type == 'basic' then
--         exports['khaizerdn-notify']:ShowNotification(source, "This is a basic notification!", 3000)
--     elseif type == 'advanced' then
--         exports['khaizerdn-notify']:ShowAdvancedNotification(source, "Test Title", "Test Subtitle", "This is an advanced notification!", "CHAR_SOCIAL_CLUB", 1, 5000)
--     elseif type == 'help' then
--         exports['khaizerdn-notify']:ShowHelpNotification(source, "This is a help notification! Press ~INPUT_CONTEXT~ to interact", 5000)
--     else
--         TriggerClientEvent('chat:addMessage', source, { args = { '^1Error', 'Invalid notification type. Use: basic, advanced, or help' } })
--     end
-- end)