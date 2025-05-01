local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("ND_Fuel:pay", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    Player.Functions.RemoveMoney('bank', math.floor(amount), "Gas Station")
    TriggerClientEvent('QBCore:Notify', src, ("Paid: $%.2f for gas."):format(amount), 'success')
end)