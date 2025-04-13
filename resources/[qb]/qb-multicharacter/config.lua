Config = {}
Config.Interior = vector3(403.0, -999.0, -99.0)              -- Interior to load where characters are previewed
Config.DefaultSpawn = vector4(435.58, -974.57, 30.72, 89.31)              -- Default spawn coords if you have start apartments disabled
Config.PedCoords = vector4(402.84, -996.88, -99.0, 174.15)   -- Create preview ped at these coordinates
Config.HiddenCoords = vector4(-779.0154, 326.1801, 196.0860, 91.0454) -- Hides your actual ped while you are in selection
Config.CamCoords = vector4(402.8405, -1000.8851, -98.4448, 0.3439) -- Position and heading from log
Config.CamRotation = vector3(-6.653927, 0.0, 0.3439)               -- Rotation from log (pitch, roll, yaw)
Config.CamFOV = 35.0                                               -- Field of view from log
Config.EnableDeleteButton = true                                      -- Define if the player can delete the character or not
Config.customNationality = false                                      -- Defines if Nationality input is custom of blocked to the list of Countries
Config.SkipSelection = true                                          -- Skip the spawn selection and spawns the player at the last location

Config.DefaultNumberOfCharacters = 2                                  -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = {                                  -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = 'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', numberOfChars = 2 },
}
