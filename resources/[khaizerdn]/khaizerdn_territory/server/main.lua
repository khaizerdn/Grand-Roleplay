local Config = require 'config'
local oxmysql = exports.oxmysql

local blipName = nil

-- Load from DB
CreateThread(function()
    local result = oxmysql:query_async('SELECT blip_name FROM khaizerdn_territory ORDER BY created_at DESC LIMIT 1')
    if result and result[1] then
        blipName = result[1].blip_name
    end
end)

-- Discord log utility
local function sendDiscordLog(name, citizenid, license)
    local embed = {
        {
            title = "🔓 Territory Captured",
            description = ("**Blip Name:** %s\n**CitizenID:** %s\n**License:** %s"):format(name, citizenid, license),
            color = 16753920,
            footer = {
                text = os.date("Hack Logged on %Y-%m-%d %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = 'Hack Logger',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Player loaded blip sync
AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local src = player.source
    TriggerClientEvent("hack:syncBlip", src, blipName)
end)

RegisterNetEvent("hack:requestBlipSync", function()
    TriggerClientEvent("hack:syncBlip", source, blipName)
end)

RegisterNetEvent("hack:setBlipName", function(name)
    local src = source
    if type(name) ~= "string" or name == "" then return end

    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local license = Player.PlayerData.license -- Adjust if needed

    if not citizenid or not license then return end

    blipName = name

    -- Sync to all players
    TriggerClientEvent("hack:syncBlip", -1, blipName)

    -- Save to DB
    oxmysql:insert('INSERT INTO khaizerdn_territory (blip_name, citizenid, license) VALUES (?, ?, ?)', {
        name, citizenid, license
    }, function(id)
        if id then
            print(('[Hack] Blip name "%s" saved by %s'):format(name, citizenid))
        end
    end)

    -- Send Discord log
    sendDiscordLog(name, citizenid, license)
end)
