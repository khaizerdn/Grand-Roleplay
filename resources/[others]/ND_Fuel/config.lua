config = {
    jerryCanPrice = 50, -- jery cans can be purchased from the gas statoin.
    jerryCanrefillCost = 20, -- The price of the jerrycans refill, this will be calculated and adjusted to how much is left in it.
    fuelCostMultiplier = 0.1, -- 2.0 will double the price of fuel and 1.5 will increase it by half.

    -- Class multipliers. If you want SUVs to use less fuel, you can change it to anything under 1.0, and vise versa.
    vehicleClasses = {
        [0] = 0.05, -- Compacts
        [1] = 0.05, -- Sedans
        [2] = 0.07, -- SUVs
        [3] = 0.05, -- Coupes
        [4] = 0.07, -- Muscle
        [5] = 0.06, -- Sports Classics
        [6] = 0.06, -- Sports
        [7] = 0.07, -- Super
        [8] = 0.03, -- Motorcycles
        [9] = 0.05, -- Off-road
        [10] = 0.05, -- Industrial
        [11] = 0.05, -- Utility
        [12] = 0.05, -- Vans
        [13] = 0.00, -- Cycles
        [14] = 0.05, -- Boats
        [15] = 0.5, -- Helicopters
        [16] = 0.5, -- Planes
        [17] = 0.05, -- Service
        [18] = 0.05, -- Emergency
        [19] = 0.05, -- Military
        [20] = 0.05, -- Commercial
        [21] = 0.05, -- Trains
    },

    electricVehicles = {
        `Imorgon`,
        `Neon`,
        `Raiden`,
        `Cyclone`,
        `Voltic`,
        `Voltic2`,
        `Tezeract`,
        `Dilettante`,
        `Dilettante2`,
        `Airtug`,
        `Caddy`,
        `Caddy2`,
        `Caddy3`,
        `Surge`,
        `Khamelion`,
        `RCBandito`
    },

    blipLocations = {
        vector3(49.4187, 2778.793, 58.043),
        vector3(263.894, 2606.463, 44.983),
        vector3(1039.958, 2671.134, 39.550),
        vector3(1207.260, 2660.175, 37.899),
        vector3(2539.685, 2594.192, 37.944),
        vector3(2679.858, 3263.946, 55.240),
        vector3(2005.055, 3773.887, 32.403),
        vector3(1687.156, 4929.392, 42.078),
        vector3(1701.314, 6416.028, 32.763),
        vector3(179.857, 6602.839, 31.868),
        vector3(-94.4619, 6419.594, 31.489),
        vector3(-2554.996, 2334.40, 33.078),
        vector3(-1800.375, 803.661, 138.651),
        vector3(-1437.622, -276.747, 46.207),
        vector3(-2096.243, -320.286, 13.168),
        vector3(-724.619, -935.1631, 19.213),
        vector3(-526.019, -1211.003, 18.184),
        vector3(-70.2148, -1761.792, 29.534),
        vector3(265.648, -1261.309, 29.292),
        vector3(819.653, -1028.846, 26.403),
        vector3(1208.951, -1402.567,35.224),
        vector3(1181.381, -330.847, 69.316),
        vector3(620.843, 269.100, 103.089),
        vector3(2581.321, 362.039, 108.468),
        vector3(176.631, -1562.025, 29.263),
        vector3(176.631, -1562.025, 29.263),
        vector3(-319.292, -1471.715, 30.549),
        vector3(1784.324, 3330.55, 41.253)
    },

    pumpModels = {
        [-2007231801] = true,
        [1339433404] = true,
        [1694452750] = true,
        [1933174915] = true,
        [-462817101] = true,
        [-469694731] = true,
        [-164877493] = true
    },

    -- you can spawn pump here. Search up gta objects and then search pump.
    addPumps = {
        -- {hash = "prop_gas_pump_old2", x = 721.93, y = 1480.80, z = 5.06},
    }
}