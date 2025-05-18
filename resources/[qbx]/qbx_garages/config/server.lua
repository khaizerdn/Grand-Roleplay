return {
    autoRespawn = false, -- True == auto respawn cars that are outside into your garage on script restart, false == does not put them into your garage and players have to go to the impound
    warpInVehicle = false, -- If false, player will no longer warp into vehicle upon taking the vehicle out.
    doorsLocked = true, -- If true, the doors will be locked upon taking the vehicle out.
    distanceCheck = 5.0, -- The distance that needs to bee clear to let the vehicle spawn, this prevents vehicles stacking on top of each other
    ---calculates the automatic impound fee.
    ---@param vehicleId integer
    ---@param modelName string
    ---@return integer fee
    calculateImpoundFee = function(vehicleId, modelName)
        local vehCost = VEHICLES[modelName].price
        return qbx.math.round(vehCost * 0.02) or 0
    end,

    ---@class GarageBlip
    ---@field name? string -- Name of the blip. Defaults to garage label.
    ---@field sprite? number -- Sprite for the blip. Defaults to 357
    ---@field color? number -- Color for the blip. Defaults to 3.

    ---The place where the player can access the garage and spawn a car
    ---@class AccessPoint
    ---@field coords vector4 where the garage menu can be accessed from
    ---@field blip? GarageBlip
    ---@field spawn? vector4 where the vehicle will spawn. Defaults to coords
    ---@field dropPoint? vector3 where a vehicle can be stored, Defaults to spawn or coords

    --- @class GarageConfig
    --- @field label string
    --- @field type? GarageType
    --- @field vehicleType VehicleType
    --- @field groups? string | string[] | table<string, number>
    --- @field shared? boolean
    --- @field states? VehicleState | VehicleState[]
    --- @field skipGarageCheck? boolean
    --- @field canAccess? fun(source: number): boolean
    --- @field accessPoints AccessPoint[]
    --- @field maxVehicles? integer -- Maximum number of vehicles that can be stored in this garage

    ---@type table<string, GarageConfig>
    garages = {

        marlowe_vineyard_garage_1 = {
            label = 'Marlowe Vineyard Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 1, -- Added vehicle limit
            accessPoints = {
                {
                    points = {
                        vec3(-1914.6, 2046.88, 140.74),
                        vec3(-1919.05, 2048.08, 140.74),
                        vec3(-1917.86, 2053.31, 140.74),
                        vec3(-1909.13, 2053.31, 140.74)
                    },
                    blipCoords = vec3(-1904.63, 2050.48, 140.73),
                    spawn = vec4(-1904.31, 2042.33, 140.74, 185.72),
                }
            },
        },

        -- marlowe_vineyard_garage_2 = {
        --     label = 'Marlowe Vineyard Garage',
        --     vehicleType = VehicleType.CAR,
        --     shared = true,
        --     allowUnowned = true,
        --     maxVehicles = 1, -- Added vehicle limit
        --     accessPoints = {
        --         {
        --             -- blip = {
        --             --     name = 'La Fuente Blanca Garage',
        --             --     sprite = 357,
        --             --     color = 3,
        --             -- },
        --             coords = vec4(-1915.1, 2051.75, 140.74, 75.31),
        --             spawn = vec4(-1919.87, 2052.85, 140.96, 257.94),
        --         }
        --     },
        -- },

        -- la_fuente_blanca_garage_1 = {
        --     label = 'La Fuente Blanca Garage',
        --     vehicleType = VehicleType.CAR,
        --     shared = true,
        --     allowUnowned = true,
        --     maxVehicles = 1, -- Added vehicle limit
        --     accessPoints = {
        --         {
        --             -- blip = {
        --             --     name = 'La Fuente Blanca Garage',
        --             --     sprite = 357,
        --             --     color = 3,
        --             -- },
        --             coords = vec4(1398.47, 1114.67, 113.84, -135.94),
        --             spawn = vec4(1400.69, 1117.27, 113.86, 47.23),
        --         }
        --     },
        -- },

        -- la_fuente_blanca_garage_2 = {
        --     label = 'La Fuente Blanca Garage',
        --     vehicleType = VehicleType.CAR,
        --     shared = true,
        --     allowUnowned = true,
        --     maxVehicles = 1, -- Added vehicle limit
        --     accessPoints = {
        --         {
        --             -- blip = {
        --             --     name = 'La Fuente Blanca Garage',
        --             --     sprite = 357,
        --             --     color = 3,
        --             -- },
        --             coords = vec4(1404.68, 1114.63, 113.84, -143.71),
        --             spawn = vec4(1406.82, 1117.07, 113.86, 50.59),
        --         }
        --     },
        -- },

        -- burtongarage = {
        --     label = 'Burton Public Garage',
        --     vehicleType = VehicleType.CAR,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Burton Public Garage',
        --                 sprite = 357,
        --                 color = 3,
        --             },
        --             coords = vec4(-310.8, -58.39, 54.42, 67.74),
        --             spawn = vec4(-317.96, -57.17, 53.82, 161.75),
        --         }
        --     },
        -- },

        -- intairport = {
        --     label = 'Airport Hangar',
        --     vehicleType = VehicleType.AIR,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Hangar',
        --                 sprite = 360,
        --                 color = 3,
        --             },
        --             coords = vec4(-1025.34, -3017.0, 13.95, 331.99),
        --             spawn = vec4(-979.2, -2995.51, 13.95, 52.19),
        --         }
        --     },
        -- },
        -- higginsheli = {
        --     label = 'Higgins Helitours',
        --     vehicleType = VehicleType.AIR,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Hangar',
        --                 sprite = 360,
        --                 color = 3,
        --             },
        --             coords = vec4(-722.12, -1472.74, 5.0, 140.0),
        --             spawn = vec4(-724.83, -1443.89, 5.0, 140.0),
        --         }
        --     },
        -- },
        -- airsshores = {
        --     label = 'Sandy Shores Hangar',
        --     vehicleType = VehicleType.AIR,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Hangar',
        --                 sprite = 360,
        --                 color = 3,
        --             },
        --             coords = vec4(1757.74, 3296.13, 41.15, 142.6),
        --             spawn = vec4(1740.88, 3278.99, 41.09, 189.46),
        --         }
        --     },
        -- },
        -- lsymc = {
        --     label = 'LSYMC Boathouse',
        --     vehicleType = VehicleType.SEA,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Boathouse',
        --                 sprite = 356,
        --                 color = 3,
        --             },
        --             coords = vec4(-794.64, -1510.89, 1.6, 201.55),
        --             spawn = vec4(-793.58, -1501.4, 0.12, 111.5),
        --         }
        --     },
        -- },
        -- paleto = {
        --     label = 'Paleto Boathouse',
        --     vehicleType = VehicleType.SEA,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Boathouse',
        --                 sprite = 356,
        --                 color = 3,
        --             },
        --             coords = vec4(-277.4, 6637.01, 7.5, 40.51),
        --             spawn = vec4(-289.2, 6637.96, 1.01, 45.5),
        --         }
        --     },
        -- },
        -- millars = {
        --     label = 'Millars Boathouse',
        --     vehicleType = VehicleType.SEA,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Boathouse',
        --                 sprite = 356,
        --                 color = 3,
        --             },
        --             coords = vec4(1299.02, 4216.42, 33.91, 166.8),
        --             spawn = vec4(1296.78, 4203.76, 30.12, 169.03),
        --         }
        --     },
        -- },

        -- -- Job Garages
        -- police = {
        --     label = 'Police',
        --     vehicleType = VehicleType.CAR,
        --     groups = 'police',
        --     accessPoints = {
        --         {
        --             coords = vec4(454.6, -1017.4, 28.4, 0),
        --             spawn = vec4(438.4, -1018.3, 27.7, 90.0),
        --         }
        --     },
        -- },

        -- -- Impound Lots
        -- impoundlot = {
        --     label = 'Impound Lot',
        --     type = GarageType.DEPOT,
        --     states = {VehicleState.OUT, VehicleState.IMPOUNDED},
        --     skipGarageCheck = true,
        --     vehicleType = VehicleType.CAR,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Impound Lot',
        --                 sprite = 68,
        --                 color = 3,
        --             },
        --             coords = vec4(-354.94, -75.68, 45.66, 168.55),
        --             spawn = vec4(-360.63, -75.85, 45.06, 71.6),
        --         }
        --     },
        -- },
        -- airdepot = {
        --     label = 'Air Depot',
        --     type = GarageType.DEPOT,
        --     states = {VehicleState.OUT, VehicleState.IMPOUNDED},
        --     skipGarageCheck = true,
        --     vehicleType = VehicleType.AIR,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'Air Depot',
        --                 sprite = 359,
        --                 color = 3,
        --             },
        --             coords = vec4(-1244.35, -3391.39, 13.94, 59.26),
        --             spawn = vec4(-1269.03, -3376.7, 13.94, 330.32),
        --         }
        --     },
        -- },
        -- seadepot = {
        --     label = 'LSYMC Depot',
        --     type = GarageType.DEPOT,
        --     states = {VehicleState.OUT, VehicleState.IMPOUNDED},
        --     skipGarageCheck = true,
        --     vehicleType = VehicleType.SEA,
        --     accessPoints = {
        --         {
        --             blip = {
        --                 name = 'LSYMC Depot',
        --                 sprite = 356,
        --                 color = 3,
        --             },
        --             coords = vec4(-772.71, -1431.11, 1.6, 48.03),
        --             spawn = vec4(-729.77, -1355.49, 1.19, 142.5),
        --         }
        --     },
        -- },
    },
}
