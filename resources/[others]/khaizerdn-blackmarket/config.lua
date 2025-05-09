Config = {}

Config.Shops = {
    blackmarket = {
        ped = {
            model = 'g_m_y_mexgoon_01',
            coords = vec4(94.8, 3748.83, 39.72, 305.32),
            animation = {
                dict = 'timetable@ron@ig_3_couch',
                clip = 'base'
            }
        },

        -- Interaction Configuration
        UseTarget = false,
        distanceTarget = 1.5,
        distanceZone = 1.0,
        labelTarget = 'Talk to Dealer',
        labelZone = 'Press [E] to browse black market.',
        coords = vec3(95.66, 3749.5, 40.72),

        -- Font Awesome Icon
        icon = 'fas fa-skull-crossbones',

        -- Shop Data
        shop = {
            name = 'blackmarket',
            inventory = {
                { name = 'weapon_pistol', price = 5000, count = 10 },
                { name = 'ammo-9', price = 50, count = 100 },
                { name = 'lockpick', price = 200, count = 20 }
            }
        }
    }
}

if GetResourceState('ox_inventory') == 'started' then
    for k, v in pairs(Config.Shops) do
        TriggerEvent('ox_inventory:registerShop', v.shop.name, {
            name = v.shop.name:gsub("^%l", string.upper),
            inventory = v.shop.inventory
        })
    end
end
