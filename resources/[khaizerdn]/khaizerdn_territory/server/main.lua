local Config = require 'config'
local oxmysql = exports.oxmysql
local blipStates = {}
local lastHacks = {} -- [group_name] = UNIX timestamp in seconds

-- Load existing blip states and last hack timestamps from DB
CreateThread(function()
    local result = oxmysql:query_async('SELECT id_name, blip_name, citizenid, license, last_hacked FROM khaizerdn_territory')
    for _, row in pairs(result or {}) do
        blipStates[row.id_name] = row.blip_name
        lastHacks[row.id_name] = tonumber(row.last_hacked) or 0
    end
end)

RegisterNetEvent('hack:requestBlipSync', function()
    TriggerClientEvent('hack:syncBlips', source, blipStates)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    TriggerClientEvent('hack:syncBlips', player.source, blipStates)
end)

lib.callback.register('hack:checkCooldown', function(source, group_name)
    local territory = Config.Territories[group_name]
    if not territory then return { passed = false, remaining = 0 } end

    local cooldownSeconds = territory.cooldownSeconds or 10
    local now = os.time()
    local last = lastHacks[group_name] or 0
    local elapsed = now - last

    if elapsed >= cooldownSeconds then
        return { passed = true }
    else
        return { passed = false, remaining = cooldownSeconds - elapsed }
    end
end)

RegisterNetEvent('hack:setBlipName', function(group_name, blip_name)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Config.Territories[group_name] or type(blip_name) ~= 'string' or blip_name == '' or not Player then return end

    local cooldownSeconds = Config.Territories[group_name].cooldownSeconds or 0
    local now = os.time()
    local last = lastHacks[group_name] or 0

    if cooldownSeconds > 0 then
        local elapsed = now - last
        if elapsed < cooldownSeconds then return end
    end

    -- Passed cooldown check; update states and DB
    blipStates[group_name] = blip_name
    lastHacks[group_name] = now
    TriggerClientEvent('hack:syncBlips', -1, blipStates)

    oxmysql:insert([[
        INSERT INTO khaizerdn_territory (id_name, blip_name, citizenid, license, last_hacked)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            blip_name = VALUES(blip_name),
            citizenid = VALUES(citizenid),
            license = VALUES(license),
            last_hacked = VALUES(last_hacked)
    ]], {
        group_name,
        blip_name,
        Player.PlayerData.citizenid,
        Player.PlayerData.license,
        now
    })

    local embed = {{
        title = '🔓 Territory Captured',
        description = ('**ID:** %s\n**Name:** %s\n**CID:** %s\n**License:** %s'):format(group_name, blip_name, Player.PlayerData.citizenid, Player.PlayerData.license),
        color = 16753920,
        footer = { text = os.date('Logged %Y-%m-%d %H:%M:%S') }
    }}

    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST',
        json.encode({ username = 'Territory Logger', embeds = embed }),
        { ['Content-Type'] = 'application/json' }
    )
end)