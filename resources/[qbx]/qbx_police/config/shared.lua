return {
    timeout = 10000,
    maxSpikes = 5,
    policePlatePrefix = 'LSPD',
    objects = {
        cone = {model = `prop_roadcone02a`, freeze = false},
        barrier = {model = `prop_barrier_work06a`, freeze = true},
        roadsign = {model = `prop_snow_sign_road_06g`, freeze = true},
        tent = {model = `prop_gazebo_03`, freeze = true},
        light = {model = `prop_worklight_03b`, freeze = true},
        chair = {model = `prop_chair_08`, freeze = true},
        chairs = {model = `prop_chair_pile_01`, freeze = true},
        tabe = {model = `prop_table_03`, freeze = true},
        monitor = {model = `des_tvsmash_root`, freeze = true},
    },

    locations = {
        duty = {
            vec4(-565.49, -127.64, 37.44, 53.10)
        },
        vehicle = {
            vec4(-565.90, -120.70, 32.69, 24.02),
        },
        stash = { -- Not currently used, use ox_inventory stashes
            -- vec3(-548.21, -113.04, 37.03),
        },
        impound = {
            vec3(-571.30, -122.72, 32.69)
        },
        helicopter = {
            vec4(-576.23, -180.73, 37.04, -66.28)
        },
        armory = { -- Not currently used, use ox_inventory shops
            -- vec3(462.23, -981.12, 30.68),
        },
        trash = {
            -- vec3(-569.27, -126.58, 36.86),
        },
        fingerprint = {
            vec3(-563.18, -126.68, 37.44),
        },
        evidence = { -- Not currently used, use ox_inventory stash system
        },
        stations = {
            {label = 'Rockford Hills PoliceStation', coords = vec3(-560.71, -133.88, 37.18)},
            -- {label = 'Mission Row Police Station', coords = vec3(434.0, -983.0, 30.7)},
            -- {label = 'Sandy Shores Police Station', coords = vec3(1853.4, 3684.5, 34.3)},
            -- {label = 'Vinewood Police Station', coords = vec3(637.1, 1.6, 81.8)},
            -- {label = 'Vespucci Police Station', coords = vec3(-1092.6, -808.1, 19.3)},
            -- {label = 'Davis Police Station', coords = vec3(368.0, -1618.8, 29.3)},
            -- {label = 'Paleto Bay Police Station', coords = vec3(-448.4, 6011.8, 31.7)},
        },
    },

    radars = {
        -- /!\ The maxspeed(s) need to be in an increasing order /!\
        -- If you don't want to fine people just do that: 'config.speedFines = false'
        -- fine if you're maxspeed or less over the speedlimit
        -- (i.e if you're at 41 mph and the radar's limit is 35 you're 6mph over so a 25$ fine)
        speedFines = {
            {fine = 25, maxSpeed = 10 },
            {fine = 50, maxSpeed = 30},
            {fine = 250, maxSpeed = 80},
            {fine = 500, maxSpeed = 180},
        }
    }
}
