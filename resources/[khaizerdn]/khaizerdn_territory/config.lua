local Config = {}

-- Hack terminal position
Config.HackRadius = 1.0
Config.DiscordWebhook = 'https://discord.com/api/webhooks/1372378941649588304/ssiFEtX33d07R8PczoeYJ7E-Jn_jfLR2YALW3gnH08O6hr059-_uhXG4MZZruMLZIxxD'
Config.HackCooldown = 600

-- Initial/default blip state
Config.Territories = {
    lafuenteblanca = {
        cooldownSeconds = 14400,
        hackLocation = vec3(1393.25, 1160.15, 114.33),
        blip = {
            coords = vec3(1382.03, 1147.64, 114.33),
            default = {
                name = "La Fuente Blanca",
                sprite = 176,
                color = 1
            }
        }
    },
    marlowevineyard = {
        cooldownSeconds = 14400,
        hackLocation = vec3(-1876.82, 2059.16, 145.57),
        blip = {
            coords = vec3(-1888.26, 2049.94, 140.98),
            default = {
                name = "Marlowe Vineyard",
                sprite = 176,
                color = 1
            }
        }
    },
}

return Config