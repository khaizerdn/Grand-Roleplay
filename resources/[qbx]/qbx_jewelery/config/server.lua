return {
    timeOut = 2700000,
    minimumPolice = 0,
    notEnoughPoliceNotify = true,
    reward = {
        minAmount = 1,
        maxAmount = 2,
        items = {
            [1] = { name = 'silver_ring', min = 1, max = 5 },
            [2] = { name = 'gold_ring', min = 1, max = 3 },
            [3] = { name = 'diamond_ring', min = 1, max = 2 },

            [4] = { name = 'silver_necklace', min = 1, max = 4 }, -- no image
            [5] = { name = 'gold_necklace', min = 1, max = 2 },
            [6] = { name = 'diamond_necklace', min = 1, max = 1 },

            [7] = { name = 'silver_bracelet', min = 1, max = 4 }, -- no image until item 15
            [8] = { name = 'gold_bracelet', min = 1, max = 3 },
            [9] = { name = 'diamond_bracelet', min = 1, max = 2 },

            [10] = { name = 'silver_earrings', min = 1, max = 6 },
            [11] = { name = 'gold_earrings', min = 1, max = 4 },
            [12] = { name = 'diamond_earrings', min = 1, max = 2 },

            [13] = { name = 'silver_watch', min = 1, max = 2 },
            [14] = { name = 'gold_watch', min = 1, max = 1 },
            [15] = { name = 'diamond_watch', min = 1, max = 1 },
        },
    },

    allowedWeapons = {
        [`weapon_smg`] = true,
        [`weapon_combatpdw`] = true,
        [`weapon_gusenberg`] = true,
    
        [`weapon_pumpshotgun`] = true,
        [`weapon_pumpshotgun_mk2`] = true,
        [`weapon_sawnoffshotgun`] = true,
        [`weapon_assaultshotgun`] = true,
        [`weapon_bullpupshotgun`] = true,
        [`weapon_musket`] = true,
        [`weapon_heavyshotgun`] = true,
        [`weapon_dbshotgun`] = true,
        [`weapon_autoshotgun`] = true,
        [`weapon_combatshotgun`] = true,
    
        [`weapon_assaultrifle`] = true,
        [`weapon_assaultrifle_mk2`] = true,
        [`weapon_carbinerifle`] = true,
        [`weapon_carbinerifle_mk2`] = true,
        [`weapon_advancedrifle`] = true,
        [`weapon_specialcarbine`] = true,
        [`weapon_specialcarbine_mk2`] = true,
        [`weapon_bullpuprifle`] = true,
        [`weapon_bullpuprifle_mk2`] = true,
        [`weapon_compactrifle`] = true,
        [`weapon_militaryrifle`] = true,
        [`weapon_heavyrifle`] = true,
        [`weapon_tacticalrifle`] = true,
    },
}
