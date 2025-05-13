local Config = {}

-- Hack terminal position
Config.HackLocation = vec3(1393.25, 1160.15, 114.33)
Config.HackRadius = 2.0

-- Initial/default blip state
Config.Blip = {
    coords = vec3(1382.03, 1147.64, 114.33),
    default = {
        name = "Capture Territory",
        sprite = 84,
        color = 1
    }
}

return Config
