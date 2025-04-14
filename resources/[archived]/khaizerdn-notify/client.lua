local QBCore = exports['qb-core']:GetCoreObject()

-- Show Advanced Notification
RegisterNetEvent('khaizerdn-notify:ShowAdvancedNotification')
AddEventHandler('khaizerdn-notify:ShowAdvancedNotification', function(title, subtitle, message, icon, iconType, duration)
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
end)

-- Show Help Notification
RegisterNetEvent('khaizerdn-notify:ShowHelpNotification')
AddEventHandler('khaizerdn-notify:ShowHelpNotification', function(message, duration)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end)

-- Show Basic Notification
RegisterNetEvent('khaizerdn-notify:ShowNotification')
AddEventHandler('khaizerdn-notify:ShowNotification', function(message, duration)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
    
    PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
    
    local timer = duration or 3000
    Citizen.Wait(timer)
    ThefeedRemoveItem()
end)

-- Client-side exports
exports('ShowNotification', function(message, duration)
    TriggerEvent('khaizerdn-notify:ShowNotification', message, duration)
end)

exports('ShowAdvancedNotification', function(title, subtitle, message, icon, iconType, duration)
    TriggerEvent('khaizerdn-notify:ShowAdvancedNotification', title, subtitle, message, icon, iconType, duration)
end)

exports('ShowHelpNotification', function(message, duration)
    TriggerEvent('khaizerdn-notify:ShowHelpNotification', message, duration)
end)