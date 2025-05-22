return {
    cityhalls = {
        {
            coords = vec3(-527.26, -234.95, 37.93),
            showBlip = true,
            blip = {
                label = 'City Services',
                shortRange = true,
                sprite = 419,
                display = 4,
                scale = 1,
                colour = 0,
            },
            licenses = {
                ['id'] = {
                    item = 'id_card',
                    label = 'ID',
                    cost = 30,
                },
                ['driver'] = {
                    item = 'driver_license',
                    label = 'Driver License',
                    cost = 40,
                },
                ['weapon'] = {
                    item = 'weaponlicense',
                    label = 'Weapon License',
                    cost = 300,
                },
            },
        },
    },

    employment = {
        enabled = true, -- Set to false to disable the employment menu
        jobs = {
            unemployed = 'Unemployed',
            trucker = 'Trucker',
            taxi = 'Taxi',
            tow = 'Tow Truck',
            reporter = 'News Reporter',
            garbage = 'Garbage Collector',
            bus = 'Bus Driver',
        },
    },
}
