---@type WeedSharedConfig
return {
    plantsSpawnType = 'both', -- Determine where plants are allowed to spawn
    plants = {
        weed_seed = {
            label = ' Weed Plant',
            item = 'weed_bud',
            stages = {
                'bkr_prop_weed_01_small_01c',
                'bkr_prop_weed_01_small_01b',
                'bkr_prop_weed_01_small_01a',
                'bkr_prop_weed_med_01b',
                'bkr_prop_weed_lrg_01a',
                'bkr_prop_weed_lrg_01b',
                'bkr_prop_weed_lrg_01b'
            }
        },
    },
    stageProps = {
        'bkr_prop_weed_01_small_01c',
        'bkr_prop_weed_01_small_01b',
        'bkr_prop_weed_01_small_01a',
        'bkr_prop_weed_med_01b',
        'bkr_prop_weed_lrg_01a',
        'bkr_prop_weed_lrg_01b',
        'bkr_prop_weed_lrg_01b'
    },
    items = {
        nutrition = 'weed_nutrition',
        emptyBag = 'ziplockbag_2'
    }
}
