Config = {}

-- Debug Information
Config.Debug = false

-- Locales
Config.Language = 'en' -- Locale language

-- Framework Related
Config.Framework = 'Qbox' -- Supports Qbox, QB, ESX & Mythic
Config.UseTarget = false -- If you don't want to use target, will use HelpNotify in bridge/functions
Config.Target = "ox_target" -- Supports ox_target, qb-target & mythic-targeting

-- Interface Related Options
Config.Notifications = "ox_lib" -- Supports ox_lib, qb, esx, mythic, okok, sd-notify, wasabi_notify, gta or custom
Config.Progress = "ox_lib_bar" -- Support ox_lib_bar, ox_lib_circle or mythic
Config.HelpNotify = "ox_lib" -- Supports ox_lib and gtao
Config.UseProgressBar = false -- Whether to display a progress bar during till robbery

-- Police & Dispatch Related
Config.Dispatch = "ps-dispatch" -- Supports cd_dispatch, qs-dispatch, ps-dispatch, rcore_dispatch, mythic-mdt, custom
Config.DispatchJobs = { "police" } -- Only for Qbox, QB & ESX
Config.NetworkAlertTimeout = 120 -- How often in seconds it limits the network alert so it can only be sent once and then have to wait this long before sending again (prevents spam)
Config.RequiredPolice = 0 -- How many police on duty to start heist

-- Cooldown
Config.GlobalCooldown = 0 -- In seconds currently at 15 minutes
Config.UseStoreCooldown = true -- Individual cooldown for different stores aswell as global
Config.StoreCooldown = 0 -- In seconds currently at 45 minutes

-- Robbery Loot
Config.UseMoneyItem = true -- If you want to give them money as an item or not
Config.BlackMoney = true -- If you want to give them black money or not
Config.TillValue = { min = 250, max = 800 }
Config.SafeItems = {
    {
        item = "black_money",
        amount = { min = 750, max = 2400 },
        chance = 30
    }
}

-- All the different store location data
Config.Locations = {
    -- General Shops
    {
        ped = vec4(2676.38, 3279.9, 55.25, 331.74),
        safe = vec4(2674.7, 3288.57, 54.24, 154.33),
        network = {
            coords = vec3(2672.87060546875, 3288.09326171875, 55.23943328857422),
            radius = 0.6
        },
        robbable = true -- Whether this store can be robbed
    },
    {
        ped = vec4(-2966.12, 391.5, 15.05, 86.08),
        safe = vec4(-2959.03, 387.61, 13.04, 0.58),
        network = {
            coords = vec3(-2957.36474609375, 390.2129211425781, 14.49756336212158),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(1958.91, 3741.28, 32.36, 300.77),
        safe = vec4(1961.91, 3749.47, 31.34, 119.41),
        network = {
            coords = vec3(1960.0970458984376, 3750.116943359375, 32.38667297363281),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(1698.36, 4922.29, 42.07, 325.64),
        safe = vec4(1707.32, 4919.07, 41.06, 57.39),
        network = {
            coords = vec3(1707.291259765625, 4921.75634765625, 42.01290893554687),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(372.6, 328.15, 103.58, 256.76),
        safe = vec4(380.37, 332.08, 102.57, 77.41),
        network = {
            coords = vec3(379.6080322265625, 333.66180419921877, 103.54884338378906),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(1134.04, -983.12, 46.42, 277.56),
        safe = vec4(1126.24, -980.77, 44.42, 184.81),
        network = {
            coords = vec3(1125.1610107421876, -983.6082763671875, 45.8283805847168),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(1164.93, -322.08, 69.22, 100.89),
        safe = vec4(1160.77, -313.69, 68.21, 192.51),
        network = {
            coords = vec3(1158.995361328125, -315.3978271484375, 69.1527099609375),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(-705.78, -915.06, 19.23, 90.86),
        safe = vec4(-708.58, -904.25, 18.22, 181.12),
        network = {
            coords = vec3(-710.4667358398438, -905.4218139648438, 19.13999557495117),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(-1221.31, -908.18, 12.33, 33.58),
        safe = vec4(-1220.04, -916.32, 10.33, 302.49),
        network = {
            coords = vec3(-1216.9649658203126, -915.9669799804688, 11.73851585388183),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(-1486.52, -377.39, 40.17, 134.64),
        safe = vec4(-1479.06, -374.17, 38.16, 50.64),
        network = {
            coords = vec3(-1479.7227783203126, -371.64654541015627, 39.5917854309082),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(-46.11, -1757.71, 29.43, 50.84),
        safe = vec4(-42.26, -1749.3, 28.42, 138.63),
        network = {
            coords = vec3(-44.71, -1748.96, 29.2),
            radius = 0.6,
        },
        robbable = true
    },
    {
        ped = vec4(24.09, -1345.62, 29.51, 270.84),
        safe = vec4(30.96, -1339.91, 28.5, 89.05),
        network = {
            coords = vec3(29.52338027954101, -1338.5648193359376, 29.50686836242675),
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(-3040.46, 583.65, 7.92, 18.68),
        safe = vec4(-3047.52, 587.96, 6.91, 196.38),
        network = {
            coords = vec3(-3048.66, 586.72, 7.71), 
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(-3243.98, 999.74, 12.84, 355.13),
        safe = vec4(-3249.15, 1006.64, 11.83, 176.5),
        network = {
            coords = vec3(-3250.37, 1005.74, 12.63), 
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(1728.26, 6416.91, 35.05, 244.27),
        safe = vec4(1736.81, 6419.1, 34.04, 66.12),
        network = {
            coords = vec3(1736.17, 6420.66, 34.84), 
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(549.67, 2669.72, 42.17, 98.01),
        safe = vec4(544.14, 2663.2, 41.16, 273.33),
        network = {
            coords = vec3(545.19, 2662.19, 41.96),
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(2555.51, 380.5, 108.63, 357.87),
        safe = vec4(2549.99, 387.25, 107.62, 180.7),
        network = {
            coords = vec3(2548.85, 386.19, 108.43),
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(-1820.29, 794.89, 138.13, 133.31),
        safe = vec4(-1828.39, 799.44, 137.17, 225.82),
        network = {
            coords = vec3(-1828.74, 797.46, 138.0),
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(1165.31, 2711.07, 38.16, 179.43),
        safe = vec4(1168.65, 2718.43, 36.16, 88.98),
        network = {
            coords = vec3(1166.44, 2719.45, 37.16),
            radius = 0.6
        },
        robbable = true
    },
    {
        ped = vec4(1392.15, 3606.54, 35.01, 200.85),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = true
    },
    { -- Bahamas West Mamas
        ped = vec4(-1391.8, -605.55, 30.32, 110.08),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    -- Weapon Shops
    {
        ped = vec4(-661.6, -933.25, 21.85, 180.93),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(809.53, -2159.37, 29.63, 0.35),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(1692.49, 3761.69, 34.72, 228.01),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(-331.37, 6085.68, 31.47, 225.58),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(253.89, -51.29, 69.96, 70.78),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(23.35, -1105.43, 29.81, 160.82),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(2567.26, 292.27, 108.75, 0.6),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(-1118.68, 2700.46, 18.57, 222.58),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
    {
        ped = vec4(841.72, -1035.62, 28.21, 0.75),
        safe = vec4(1395.28, 3613.23, 33.98, 201.5),
        network = {
            coords = vec3(1394.25, 3611.49, 35.01),
            radius = 0.6
        },
        robbable = false
    },
}

-- List of peds used for the cashier
Config.Peds = {
    `mp_m_shopkeep_01`
}

Config.ResetAccess = {
    Jobs = {
        ['police'] = 0
    },
    Groups = { "admin", "god" }
}