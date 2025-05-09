return {
    maxStatusValues = {
        engine = 1000.0,
        body = 1000.0,
        radiator = 100,
        axle = 100,
        brakes = 100,
        clutch = 100,
        fuel = 100,
    },
    repairCost = {
        body = 'plastic',
        radiator = 'plastic',
        axle = 'steel',
        brakes = 'iron',
        clutch = 'aluminum',
        fuel = 'plastic',
    },
    repairCostAmount = {
        engine = {
            item = 'metalscrap',
            costs = 2,
        },
        body = {
            item = 'plastic',
            costs = 3,
        },
        radiator = {
            item = 'steel',
            costs = 5,
        },
        axle = {
            item = 'aluminum',
            costs = 7,
        },
        brakes = {
            item = 'copper',
            costs = 5,
        },
        clutch = {
            item = 'copper',
            costs = 6,
        },
        fuel = {
            item = 'plastic',
            costs = 5,
        },
    },
    plates = {
        {
            coords = vec4(-343.06, -113.61, 38.41, 69.68),
            boxData = {
                heading = 69.68,
                length = 5,
                width = 2.5,
                debugPoly = true
            },
            AttachedVehicle = nil,
        },
        {
            coords = vec4(-327.91, -144.34, 38.86, 70.34),
            boxData = {
                heading = 249,
                length = 6.5,
                width = 5,
                debugPoly = false
            },
            AttachedVehicle = nil,
        },
    },
    locations = {
        exit = vec3(-369.32, -118.48, 38.7),
        duty = vec3(-339.45, -155.55, 44.59),
        stash = vec3(-337.11, -160.88, 44.59),
        vehicle = vec4(-357.49, -159.54, 38.82, 31.2),
    }
}