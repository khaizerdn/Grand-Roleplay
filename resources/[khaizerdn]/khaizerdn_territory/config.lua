local Config = {}

-- Hack terminal position
Config.HackLocation = vec3(1393.25, 1160.15, 114.33)
Config.HackRadius = 2.0
Config.DiscordWebhook = 'https://discord.com/api/webhooks/1372378941649588304/ssiFEtX33d07R8PczoeYJ7E-Jn_jfLR2YALW3gnH08O6hr059-_uhXG4MZZruMLZIxxD'
Config.HackCooldown = 600

-- Initial/default blip state
Config.Blip = {
    coords = vec3(1382.03, 1147.64, 114.33),
    default = {
        name = "Capture Territory",
        sprite = 176,
        color = 1
    }
}

return Config
