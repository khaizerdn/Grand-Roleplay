return {
    autoRespawn = false, -- True == auto respawn cars that are outside into your garage on script restart, false == does not put them into your garage and players have to go to the impound
    warpInVehicle = false, -- If false, player will no longer warp into vehicle upon taking the vehicle out.
    doorsLocked = true, -- If true, the doors will be locked upon taking the vehicle out.
    distanceCheck = 5.0, -- The distance that needs to be clear to let the vehicle spawn, this prevents vehicles stacking on top of each other
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
    ---@field points vector3[] polyzone points for the garage access area
    ---@field blip? GarageBlip
    ---@field blipCoords vector3 coordinates for the blip
    ---@field dropPoint? vector3 where a vehicle can be stored
    ---@field interact? vector3 interaction point for impound lot
    ---@field spawn? vector4 spawn point for impound lot vehicles

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

        burton_garage_1 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 15,
            accessPoints = {
                {
                    points = {
                        vec3(-323.48, -85.24, 54.75),
                        vec3(-319.29, -81.85, 54.42),
                        vec3(-368.46, -64.82, 54.42),
                        vec3(-372.5, -68.24, 54.75)
                    },
                    blip = {
                        coords = vec3(-300.34, -59.16, 49.11),
                        sprite = 357, -- Garage blip sprite
                        color = 3,    -- Blue color
                    }
                }
            },
        },

        burton_garage_2 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 6,
            accessPoints = {
                {
                    points = {
                        vec3(-373.27, -68.76, 54.75),
                        vec3(-377.93, -67.26, 54.42),
                        vec3(-385.34, -87.28, 54.42),
                        vec3(-380.71, -89.03, 54.75)

                    },
                }
            },
        },

        burton_garage_3 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 6,
            accessPoints = {
                {
                    points = {
                        vec3(-410.3, -78.15, 54.48),
                        vec3(-408.15, -82.03, 54.75),
                        vec3(-393.49, -67.82, 54.42),
                        vec3(-396.55, -64.64, 54.67)

                    },
                }
            },
        },

        burton_garage_4 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 7,
            accessPoints = {
                {
                    points = {
                        vec3(-390.96, -53.99, 54.75),
                        vec3(-386.36, -55.56, 54.42),
                        vec3(-378.23, -32.14, 54.75),
                        vec3(-382.84, -30.55, 54.75)

                    },
                }
            },
        },

        burton_garage_5 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 10,
            accessPoints = {
                {
                    points = {
                        vec3(-366.99, -35.94, 54.75),
                        vec3(-372.99, -52.86, 54.42),
                        vec3(-363.35, -56.13, 54.42),
                        vec3(-357.69, -39.18, 54.75)

                    },
                }
            },
        },

        burton_garage_6 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 3,
            accessPoints = {
                {
                    points = {
                        vec3(-348.53, -58.24, 54.42),
                        vec3(-343.24, -60.12, 54.42),
                        vec3(-339.77, -50.25, 54.42),
                        vec3(-345.22, -48.35, 54.42)

                    },
                }
            },
        },

        burton_garage_7 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 3,
            accessPoints = {
                {
                    points = {
                        vec3(-324.61, -50.65, 54.75),
                        vec3(-326.69, -56.11, 54.42),
                        vec3(-316.93, -59.5, 54.42),
                        vec3(-315.08, -53.82, 54.75)
                    },
                }
            },
        },

        burton_garage_8 = {
            label = 'Burton Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 4,
            accessPoints = {
                {
                    points = {
                        vec3(-313.95, -60.9, 54.42),
                        vec3(-308.8, -62.77, 54.63),
                        vec3(-313.37, -76.16, 54.75),
                        vec3(-318.54, -74.09, 54.42)
                    },
                }
            },
        },

        lsc_burton_garage_1 = {
            label = 'LSC Burton Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 7,
            accessPoints = {
                {
                    points = {
                        vec3(-350.55, -104.4, 45.67),
                        vec3(-348.99, -99.68, 45.67),
                        vec3(-372.21, -91.18, 45.66),
                        vec3(-373.88, -95.77, 45.66)
                    },
                }
            },
        },

        lsc_burton_garage_2 = {
            label = 'LSC Burton Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 10,
            accessPoints = {
                {
                    points = {
                        vec3(-396.01, -119.09, 38.66),
                        vec3(-391.74, -116.61, 38.64),
                        vec3(-374.91, -147.21, 38.69),
                        vec3(-378.96, -149.44, 38.69)
                    },
                }
            },
        },

        lsc_burton_garage_3 = {
            label = 'LSC Burton Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 3,
            accessPoints = {
                {
                    points = {
                        vec3(-357.95, -129.68, 38.7),
                        vec3(-362.66, -127.99, 38.7),
                        vec3(-359.13, -118.28, 38.7),
                        vec3(-354.39, -119.88, 38.75)
                    },
                }
            },
        },

        lsc_burton_garage_4 = {
            label = 'LSC Burton Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 4,
            accessPoints = {
                {
                    points = {
                        vec3(-350.37, -150.47, 39.01),
                        vec3(-344.44, -148.19, 39.01),
                        vec3(-336.54, -162.38, 39.01),
                        vec3(-342.45, -164.51, 39.02)
                    },
                }
            },
        },

        rockfordhills_garage_1 = {
            label = 'Rockford Hills Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 10,
            accessPoints = {
                {
                    points = {
                        vec3(-723.52, -69.63, 41.75),
                        vec3(-725.53, -65.26, 41.76),
                        vec3(-752.94, -79.27, 41.75),
                        vec3(-750.73, -83.5, 41.75)
                        
                    },
                    blip = {
                        coords = vec3(-716.51, -51.01, 37.83),
                        sprite = 357, -- Garage blip sprite
                        color = 3,    -- Blue color
                    }
                }
            },
        },

        rockfordhills_garage_2 = {
            label = 'Rockford Hills Public Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 15,
            accessPoints = {
                {
                    points = {
                        vec3(-897.46, -160.62, 41.88),
                        vec3(-899.64, -156.23, 41.88),
                        vec3(-948.68, -181.27, 41.88),
                        vec3(-946.58, -185.59, 41.87)
                        
                    },
                    blip = {
                        coords = vec3(-886.59, -139.97, 37.95),
                        sprite = 357, -- Garage blip sprite
                        color = 3,    -- Blue color
                    }
                }
            },
        },

        marlowe_vineyard_garage_1 = {
            label = 'Marlowe Vineyard Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 7,
            accessPoints = {
                {
                    points = {
                        vec3(-1915.39, 2058.19, 140.74),
                        vec3(-1921.74, 2059.66, 140.73),
                        vec3(-1928.18, 2030.87, 140.84),
                        vec3(-1921.91, 2028.51, 140.75)
                    },
                }
            },
        },

        marlowe_vineyard_garage_2 = {
            label = 'Marlowe Vineyard Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 5,
            accessPoints = {
                {
                    points = {
                        vec3(-1900.56, 2039.99, 140.74),
                        vec3(-1902.84, 2033.72, 140.74),
                        vec3(-1881.9, 2026.18, 140.41),
                        vec3(-1880.17, 2032.61, 140.39),
                        
                    },
                }
            },
        },

        marlowe_vineyard_garage_3 = {
            label = 'Marlowe Vineyard Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 5,
            accessPoints = {
                {
                    points = {
                        vec3(-1902.82, 2023.29, 140.76),
                        vec3(-1909.49, 2023.44, 140.75),
                        vec3(-1909.59, 1998.2, 142.13),
                        vec3(-1902.93, 1998.14, 141.95)
                        
                    },
                }
            },
        },

        lafuenteblanca_garage_1 = {
            label = 'La Fuente Blanca Garage',
            vehicleType = VehicleType.CAR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 3,
            accessPoints = {
                {
                    points = {
                        vec3(1398.33, 1114.38, 114.84),
                        vec3(1398.54, 1122.2, 114.84),
                        vec3(1417.07, 1122.37, 114.84),
                        vec3(1417.04, 1114.47, 114.83)
                        
                    },
                }
            },
        },

        intairport_garage_1 = {
            label = 'Airport Hangar',
            vehicleType = VehicleType.AIR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 5,
            accessPoints = {
                {
                    points = {
                        vec3(-1033.81, -3019.47, 13.95),
                        vec3(-969.82, -2907.01, 13.96),
                        vec3(-961.47, -2911.6, 13.96),
                        vec3(-953.74, -2899.09, 13.96),
                        vec3(-886.7, -2957.71, 13.94),
                        vec3(-897.06, -2976.06, 13.94),
                        vec3(-884.31, -2983.67, 13.95),
                        vec3(-935.36, -3072.58, 13.94)
                        
                    },
                    blip = {
                        coords = vec3(-1009.39, -2979.26, 13.95),
                        sprite = 360,
                        color = 3,
                    },
                }
            },
        },

        higginshelitours_garage_1 = {
            label = 'Higgins Helitours',
            vehicleType = VehicleType.AIR,
            shared = true,
            allowUnowned = true,
            maxVehicles = 6,
            accessPoints = {
                {
                    points = {
                        vec3(-689.93, -1450.89, 5.0),
                        vec3(-738.91, -1408.74, 5.0),
                        vec3(-776.58, -1454.68, 5.0),
                        vec3(-727.81, -1494.51, 5.0)

                        
                    },
                    blip = {
                        coords = vec3(-732.05, -1452.23, 5.0),
                        sprite = 360,
                        color = 3,
                    },
                }
            },
        },

        lapuerta_garage_1 = {
            label = 'La Puerta Dock',
            vehicleType = VehicleType.SEA,
            shared = true,
            allowUnowned = true,
            maxVehicles = 6,
            accessPoints = {
                {
                    points = {
                        vec3(-775.59, -1516.02, 1.2),
                        vec3(-795.58, -1462.7, 0.61),
                        vec3(-690.79, -1338.9, 0.8),
                        vec3(-726.75, -1308.62, 0.8),
                        vec3(-814.96, -1411.52, 1.92),
                        vec3(-850.78, -1312.66, 1.56),
                        vec3(-1006.19, -1368.39, 0.8),
                        vec3(-1015.44, -1407.27, 1.03),
                        vec3(-1011.36, -1418.4, 1.32),
                        vec3(-909.06, -1381.54, 0.82),
                        vec3(-890.52, -1430.62, 1.74),
                        vec3(-966.34, -1458.0, 1.51),
                        vec3(-947.69, -1502.31, 0.45),
                        vec3(-875.32, -1473.15, 1.11),
                        vec3(-858.67, -1518.86, 1.02)

                    },
                    blip = {
                        coords = vec3(-836.88, -1443.02, 0.79),
                        sprite = 360,
                        color = 3,
                    },
                }
            },
        },

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

        impoundlot = {
            label = 'Impound Lot',
            type = GarageType.DEPOT,
            states = {VehicleState.OUT, VehicleState.IMPOUNDED},
            skipGarageCheck = true,
            vehicleType = VehicleType.CAR,
            accessPoints = {
                {
                    interact = vec3(-354.76, -75.63, 45.67),
                    spawn = vec4(-361.29, -75.63, 45.06, 71.34),
                    blip = {
                        coords = vec3(-354.76, -75.63, 45.67),
                        sprite = 360,
                        color = 3,
                    },
                }
            },
        },

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
