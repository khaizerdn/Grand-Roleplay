local config = require 'config.server'
local sharedConfig = require 'config.shared'
local logger = require '@qbx_core.modules.logger'

lib.addCommand('createproperty', {
    help = 'Create a property at your current location',
}, function(source)
    local player = exports.qbx_core:GetPlayer(source)

    if player.PlayerData.job.name ~= 'realestate' then exports.qbx_core:Notify(source, 'Not a realtor', 'error') return end

    TriggerClientEvent('qbx_properties:client:createProperty', source)
end)

RegisterNetEvent('qbx_properties:server:createProperty', function(interior, input, coords, garage)
    local playerSource = source --[[@as number]]
    local player = exports.qbx_core:GetPlayer(playerSource)
    
    local propertyName = input[1]
    local price = input[2]
    local rentInterval = input[3] or nil -- Allow nil for non-rentable properties
    local interactData = {
        {
            type = 'logout',
            coords = sharedConfig.interiors[interior].logout
        },
        {
            type = 'clothing',
            coords = sharedConfig.interiors[interior].clothing
        },
        {
            type = 'exit',
            coords = sharedConfig.interiors[interior].exit
        }
    }
    local stashData = {
        {
            coords = sharedConfig.interiors[interior].stash,
            slots = config.apartmentStash.slots,
            maxWeight = config.apartmentStash.maxWeight,
        }
    }

    local id = MySQL.insert.await('INSERT INTO `properties` (`coords`, `property_name`, `price`, `rent_interval`, `interior`, `interact_options`, `stash_options`, `garage`, `is_selling`, `sell_price`, `keyholders`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        json.encode(coords),
        propertyName,
        price,
        rentInterval,
        interior,
        json.encode(interactData),
        json.encode(stashData),
        garage and json.encode(garage) or nil,
        true, -- Set is_selling to true
        price, -- Set sell_price to the input price
        json.encode({}) -- Set keyholders to empty array
    })

    if rentInterval then
        startRentThread(id)
    end

    logger.log({
        source = playerSource,
        event = 'qbx_properties:server:createProperty',
        message = locale('logs.property_created', propertyName),
        webhook = config.discordWebhook
    })

    TriggerClientEvent('qbx_properties:client:addProperty', -1, coords)
    TriggerClientEvent('qbx_properties:client:refreshBlips', -1) -- Refresh blips for all clients
end)