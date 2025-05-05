return {
    checkInCost = 2000, -- Price for using the hospital check-in system
    minForCheckIn = 2, -- Minimum number of people with the ambulance job to prevent the check-in system from being used

    locations = { -- Various interaction points
        duty = {
            vec3(-441.58, -318.56, 34.91),
        },
        vehicle = {
            vec4(294.578, -574.761, 43.179, 35.79),
            vec4(-234.28, 6329.16, 32.15, 222.5),
        },
        helicopter = {
            vec4(351.58, -587.45, 74.16, 160.5),
            vec4(-475.43, 5988.353, 31.716, 31.34),
        },
        armory = {
            {
                shopType = 'AmbulanceArmory',
                name = 'Armory',
                groups = { ambulance = 0 },
                inventory = {
                    { name = 'radio', price = 0 },
                    { name = 'bandage', price = 0 },
                    { name = 'painkillers', price = 0 },
                    { name = 'firstaid', price = 0 },
                    { name = 'weapon_flashlight', price = 0 },
                    { name = 'weapon_fireextinguisher', price = 0 },
                },
                locations = {
                    vec3(309.93, -602.94, 43.29)
                }
            }
        },
        roof = {
            vec3(338.54, -583.88, 74.17),
        },
        main = {
            vec3(298.62, -599.66, 43.29),
        },
        stash = {
            {
                name = 'ambulanceStash',
                label = 'Personal stash',
                weight = 100000,
                slots = 30,
                groups = { ambulance = 0 },
                owner = true, -- Set to false for group stash
                location = vec3(309.78, -596.6, 43.29)
            }
        },

        ---@class Bed
        ---@field coords vector4
        ---@field model number

        ---@type table<string, {coords: vector3, checkIn?: vector3|vector3[], beds: Bed[]}>
        hospitals = {
            mountzonah = {
                coords = vec3(-435.19, -324.13, 34.91),
                checkIn = vec3(-435.82, -325.84, 34.91),
                beds = {
                    {coords = vec4(-459.0, -279.65, 34.47, 203.0), model = 2117668672},
                    {coords = vec4(-462.75, -281.23, 34.47, 203.0), model = 2117668672},
                    {coords = vec4(-466.5, -282.76, 34.47, 203.0), model = 2117668672},
                    {coords = vec4(-469.91, -284.19, 34.47, 203.0), model = 21176686727},
                    {coords = vec4(-460.29, -288.67, 34.47, 23.0), model = 2117668672},
                    {coords = vec4(-463.69, -290.07, 34.47, 23.0), model = 2117668672},
                    {coords = vec4(-454.92, -286.48, 34.47, 23.0), model = 2117668672},
                    {coords = vec4(-466.99, -291.4, 34.47, 23.0), model = 2117668672},
                    {coords = vec4(-451.54, -285.08, 34.47, 23.0), model = 2117668672},
                    {coords = vec4(-448.38, -283.77, 34.47, 23.0), model = 2117668672},
                    {coords = vec4(-455.11, -278.04, 34.47, 203.0), model = 2117668672},
                },
            },
            -- paleto = {
            --     coords = vec3(-250, 6315, 32),
            --     checkIn = vec3(-254.54, 6331.78, 32.43),
            --     beds = {
            --         {coords = vec4(-252.43, 6312.25, 32.34, 313.48), model = 2117668672},
            --         {coords = vec4(-247.04, 6317.95, 32.34, 134.64), model = 2117668672},
            --         {coords = vec4(-255.98, 6315.67, 32.34, 313.91), model = 2117668672},
            --     },
            -- },
            jail = {
                coords = vec3(1761, 2600, 46),
                beds = {
                    {coords = vec4(1761.96, 2597.74, 45.66, 270.14), model = 2117668672},
                    {coords = vec4(1761.96, 2591.51, 45.66, 269.8), model = 2117668672},
                    {coords = vec4(1771.8, 2598.02, 45.66, 89.05), model = 2117668672},
                    {coords = vec4(1771.85, 2591.85, 45.66, 91.51), model = 2117668672},
                },
            },
        },

        stations = {
            {label = 'Mount Zonah Medical Center', coords = vec4(-448.1, -340.8, 34.5, 80.4)},
        }
    },
}