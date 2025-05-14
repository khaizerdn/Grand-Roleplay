local Config = require 'config'

local blipName = nil

RegisterNetEvent("hack:requestBlipSync", function()
    TriggerClientEvent("hack:syncBlip", source, blipName)
end)

RegisterNetEvent("hack:setBlipName", function(name)
    if type(name) ~= "string" or name == "" then return end

    blipName = name
    TriggerClientEvent("hack:syncBlip", -1, blipName)
end)
