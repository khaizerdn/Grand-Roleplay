-- client.lua
-- Register the /pcoords command for QBcore
QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('pcoords', function(source, args, rawCommand)
    -- Get the player's ped
    local ped = PlayerPedId()
    
    -- Get coordinates and heading
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Format the output string with rounded values
    local output = string.format("%.2f %.2f %.2f %.2f", coords.x, coords.y, coords.z, heading)
    
    -- Print to console
    print(output)
    
    -- Optional: Send a notification to the player
    QBCore.Functions.Notify('Coordinates printed to console (F8)', 'success')
end, false)

-- Add command suggestion for better usability
TriggerEvent('chat:addSuggestion', '/pcoords', 'Prints your current coordinates and heading to the console')