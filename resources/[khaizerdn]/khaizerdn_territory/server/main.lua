local Config = require 'config'
local oxmysql = exports.oxmysql
local blipStates = {}
local lastHacks = {} -- [id_name] = UNIX timestamp in seconds

-- Load existing blip states and last hack timestamps from DB
CreateThread(function()
    local result = oxmysql:query_async('SELECT id_name, blip_name, last_hacked FROM khaizerdn_territory')
    for _, row in pairs(result or {}) do
        blipStates[row.id_name] = row.blip_name
        lastHacks[row.id_name] = tonumber(row.last_hacked) or 0
    end
    print("Loaded territories: " .. table.concat(table.keys(Config.Territories), ", "))
end)

-- Helper function to get table keys
function table.keys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end
    return keys
end

RegisterNetEvent("hack:requestBlipSync", function()
    TriggerClientEvent("hack:syncBlips", source, blipStates)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    TriggerClientEvent("hack:syncBlips", player.source, blipStates)
end)

RegisterNetEvent("hack:checkCooldown", function(id_name)
    local src = source
    print(("Received hack:checkCooldown for %s from source %d"):format(id_name, src))
    local territory = Config.Territories[id_name]
    if not territory then
        print("Error: Territory " .. id_name .. " not found")
        return
    end

    local cooldownSeconds = territory.cooldownSeconds or 10
    local now = os.time()
    local last = lastHacks[id_name] or 0
    local elapsed = now - last

    print(("Cooldown check for %s: now=%d, last=%d, elapsed=%d, cooldownSeconds=%d"):format(id_name, now, last, elapsed, cooldownSeconds))
    if elapsed >= cooldownSeconds then
        print("Cooldown passed, triggering hack:cooldownPassed")
        TriggerClientEvent("hack:cooldownPassed", src, id_name)
    else
        local remaining = cooldownSeconds - elapsed
        print(("Cooldown active, triggering hack:cooldownBlocked with %d seconds remaining"):format(remaining))
        TriggerClientEvent("hack:cooldownBlocked", src, remaining)
    end
end)

RegisterNetEvent("hack:setBlipName", function(id_name, blip_name)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Config.Territories[id_name] or type(blip_name) ~= "string" or blip_name == "" or not Player then return end

    local cooldownSeconds = Config.Territories[id_name].cooldownSeconds or 0
    local now = os.time()
    local last = lastHacks[id_name] or 0

    print(("Hack attempt on %s: now=%d, last=%d, cooldownSeconds=%d"):format(id_name, now, last, cooldownSeconds))
    if cooldownSeconds > 0 then
        local elapsed = now - last
        if elapsed < cooldownSeconds then
            local remaining = cooldownSeconds - elapsed
            print(("Cooldown blocked for %s: elapsed=%d, remaining=%d"):format(id_name, elapsed, remaining))
            TriggerClientEvent("hack:cooldownBlocked", src, remaining)
            return
        else
            print(("Cooldown passed for %s: elapsed=%d"):format(id_name, elapsed))
        end
    end

    -- Passed cooldown check; update states and DB
    blipStates[id_name] = blip_name
    lastHacks[id_name] = now
    print(("Updated lastHacks[%s] to %d"):format(id_name, now))
    TriggerClientEvent("hack:syncBlips", -1, blipStates)

    oxmysql:insert([[
        INSERT INTO khaizerdn_territory (id_name, blip_name, citizenid, license, last_hacked)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            blip_name = VALUES(blip_name),
            citizenid = VALUES(citizenid),
            license = VALUES(license),
            last_hacked = VALUES(last_hacked)
    ]], {
        id_name,
        blip_name,
        Player.PlayerData.citizenid,
        Player.PlayerData.license,
        now
    })

    local embed = {{
        title = "🔓 Territory Captured",
        description = ("**ID:** %s\n**Name:** %s\n**CID:** %s\n**License:** %s"):format(id_name, blip_name, Player.PlayerData.citizenid, Player.PlayerData.license),
        color = 16753920,
        footer = { text = os.date("Logged %Y-%m-%d %H:%M:%S") }
    }}

    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST',
        json.encode({ username = 'Territory Logger', embeds = embed }),
        { ['Content-Type'] = 'application/json' }
    )
end)