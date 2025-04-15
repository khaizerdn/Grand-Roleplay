local QBCore = exports['qb-core']:GetCoreObject()

-- Notification exports
exports('ShowNotification', function(source, message, duration)
    TriggerClientEvent('khaizerdn-notifyV2:ShowNotification', source, message, duration)
end)

exports('ShowAdvancedNotification', function(source, title, subtitle, message, image, duration)
    TriggerClientEvent('khaizerdn-notifyV2:ShowAdvancedNotification', source, title, subtitle, message, image, duration)
end)

exports('ShowHelpNotification', function(source, message, duration)
    TriggerClientEvent('khaizerdn-notifyV2:ShowHelpNotification', source, message, duration)
end)