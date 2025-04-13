local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('noguera-devcam:checkAdmin')
AddEventHandler('noguera-devcam:checkAdmin', function()
    local src = source
    local isAdmin = false
    
    if QBCore then
        isAdmin = QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god')
    end
    
    if not isAdmin then
        isAdmin = IsPlayerAceAllowed(src, 'command.devcam')
    end
    
    TriggerClientEvent('noguera-devcam:adminResponse', src, isAdmin)
end)