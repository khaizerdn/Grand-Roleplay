local Config = require 'config'

local blipData = nil

RegisterNetEvent("hack:requestBlipSync", function()
    TriggerClientEvent("hack:syncBlip", source, blipData)
end)

RegisterNetEvent("hack:setBlipData", function(data)
    if not data or not data.name or not data.sprite or not data.color then return end

    blipData = {
        name = tostring(data.name),
        sprite = tonumber(data.sprite),
        color = tonumber(data.color)
    }

    TriggerClientEvent("hack:syncBlip", -1, blipData)
end)
