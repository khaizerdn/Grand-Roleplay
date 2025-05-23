return {
    ['testburger'] = {
        label = 'Test Burger',
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Lick it',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Squeeze it',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Bandage',
        weight = 115,
    },

    ['burger'] = {
        label = 'Burger',
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ['burgershot_burger'] = {
        label = "Burger",
        description = "Burger Shot's Burger",
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ['aldentes_pizzaslice'] = {
        label = 'Pizza Slice',
        description = "Al Dente's Pizza Slice",
        weight = 250,
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'prop_cs_hotdog_01', pos = vec3(1000.0, 0.0, -0.01), rot = vec3(0.0, 0.0, 0.0) },
            usetime = 4500,
            notification = 'You ate a pizza slice'
        }
    },

    ['cluckinbell_burger'] = {
        label = "Burger",
        description = "Clucki'n Bell Burger",
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ['cluckinbell_hotdog'] = {
        label = "Hotdog Sandwich",
        description = "Clucki'n Bell Hotdog Sandwich",
        weight = 300,
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'prop_cs_hotdog_01', pos = vec3(0.0, 0.0, -0.01), rot = vec3(.0, 0.0, 90.0) },
            usetime = 5000,
            notification = 'You ate a hotdog sandwich'
        }
    },

    ['cola'] = {
        label = 'Cola',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['sprunk'] = {
        label = 'Sprunk',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['parachute'] = {
        label = 'Parachute',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Garbage',
    },

    ['container_paperbag'] = {
        label = 'Paper Bag',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['container_ziplockbag1'] = {
        label = 'Ziplock Bag (S)',
        description = 'Small',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['container_ziplockbag2'] = {
        label = 'Ziplock Bag (M)',
        description = 'Medium',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['container_ziplockbag3'] = {
        label = 'Ziplock Bag (L)',
        description = 'Large',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },    

    ['panties'] = {
        label = 'Knickers',
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        label = 'Lockpick',
        weight = 160,
    },

    ['phone'] = {
        label = 'Phone',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
    },

    ['mustard'] = {
        label = 'Mustard',
        weight = 500,
        client = {
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'You... drank mustard'
        }
    },

    ['water'] = {
        label = 'Water',
        weight = 500,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing water'
        }
    },

    ['armour'] = {
        label = 'Bulletproof Vest',
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Clothing',
        consume = 0,
    },

    ['money'] = {
        label = 'Money',
    },

    ['black_money'] = {
        label = 'Dirty Money',
    },

    ['id_card'] = {
        label = 'Identification Card',
    },

    ['driver_license'] = {
        label = 'Drivers License',
    },

    ['weaponlicense'] = {
        label = 'Weapon License',
    },

    ['lawyerpass'] = {
        label = 'Lawyer Pass',
    },

    ['radio'] = {
        label = 'Radio',
        weight = 1000,
        stack = false,
        allowArmed = true,
        consume = 0,
         client = {
             event = 'mm_radio:client:use'
         }
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        weight = 1000,
        
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
    },

    ['screwdriverset'] = {
        label = 'Screwdriver Set',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Repair Kit',
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        weight = 4000,
    },

    ['firstaid'] = {
        label = 'First Aid',
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Individual First Aid Kit',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Painkillers',
        weight = 400,
    },

    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Steel',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Rubber',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Metal Scrap',
        weight = 100,
    },

    ['iron'] = {
        label = 'Iron',
        weight = 100,
    },

    ['copper'] = {
        label = 'Copper',
        weight = 100,
    },

    ['aluminium'] = {
        label = 'Aluminium',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Plastic',
        weight = 100,
    },

    ['aluminum'] = {
        label = 'Aluminum',
        weight = 100,
    },

    ['glass'] = {
        label = 'Glass',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'Crypto Stick',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Toaster',
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Small TV',
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Security Card A',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Security Card B',
        weight = 100,
    },

    ['drill'] = {
        label = 'Drill',
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
    },

    ['diving_gear'] = {
        label = 'Diving Gear',
        weight = 20000,
    },

    ['diving_scubacylinder'] = {
        label = 'Scuba Cylinder',
        weight = 10000,
    },

    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        weight = 10000,
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 10000,
    },

    ['jerry_can'] = {
        label = 'Jerrycan',
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Nitrous',
        weight = 1000,
    },

    ['wine'] = {
        label = 'Wine',
        weight = 500,
    },

    ['grape'] = {
        label = 'Grape',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Grape Juice',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Coffee',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Vodka',
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Whiskey',
        weight = 200,
    },

    ['beer'] = {
        label = 'beer',
        weight = 200,
    },

    ['sandwich'] = {
        label = 'beer',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Lighter',
        weight = 200,
    },

    ['binoculars'] = {
        label = 'Binoculars',
        weight = 800,
    },

    ['stickynote'] = {
        label = 'Sticky Note',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Filled Evidence Bag',
        weight = 200,
    },

    ['harness'] = {
        label = 'Harness',
        weight = 200,
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 200,
    },

    ['tool_laptop'] = {
        label = 'Laptop',
        weight = 2000,
        stack = false,
    },

    ['vehicle_key'] = {
        label = 'Vehicle Key',
        weight = 0,
        consume = 0,
    },

    -- ALL ABOUT CRAFTING

    -- TOOLS
    ['tool_herbgrinder'] = {
        label = 'Herb Grinder',
        weight = 500, -- 500g (0.5kg)
        stack = false,
    },
    
    ['tool_digitalscale'] = {
        label = 'Digital Scale',
        weight = 300, -- 300g (0.3kg)
        stack = false,
    },
    
    ['tool_tray'] = {
        label = 'Tray',
        weight = 700, -- 700g (0.7kg)
        stack = false,
    },

    ['tool_circuitboard'] = {
        label = 'Circuit Board',
        weight = 500,
    },

    ['tool_circuitboard_hacking_bank'] = {
        label = 'Circuit Board',
        description = '01000010 01100001 01101110 01101011',
        weight = 500,
    },
    
    -- CRAFTING JOINT    
    
    ['cannabis_plant'] = {
        label = 'Cannabis (Plant)',
        weight = 700, -- 700g (0.7kg)
        stack = false,
    },
    
    ['cannabis_bud'] = {
        label = 'Cannabis (Bud)',
        weight = 1,
    },
    
    ['cannabis_ground'] = {
        label = 'Cannabis (Ground)',
        weight = 0.40,
    },
    
    ['cannabis_gram'] = {
        label = 'Cannabis (Gram)',
        weight = 1,
    },
    
    ['tool_rollingpaper'] = {
        label = 'Rolling Paper',
        weight = 0.1,
    },
    
    ['joint'] = {
        label = 'Joint',
        weight = 1.1,
    },    
    -- END OF CRAFTING JOINT

    -- RINGS (3g to 9g)
    ['valuable_silver_ring'] = { label = 'Silver Ring', weight = 5 },
    ['valuable_gold_ring'] = { label = 'Gold Ring', weight = 7 },
    ['valuable_diamond_ring'] = { label = 'Diamond Ring', weight = 9 },

    -- NECKLACES (15g to 45g)
    ['valuable_silver_necklace'] = { label = 'Silver Necklace', weight = 25 },
    ['valuable_gold_necklace'] = { label = 'Gold Necklace', weight = 35 },
    ['valuable_diamond_necklace'] = { label = 'Diamond Necklace', weight = 45 },

    -- BRACELETS (10g to 30g)
    ['valuable_silver_bracelet'] = { label = 'Silver Bracelet', weight = 18 },
    ['valuable_gold_bracelet'] = { label = 'Gold Bracelet', weight = 24 },
    ['valuable_diamond_bracelet'] = { label = 'Diamond Bracelet', weight = 30 },

    -- EARRINGS (2g to 6g)
    ['valuable_silver_earrings'] = { label = 'Silver Earrings', weight = 4 },
    ['valuable_gold_earrings'] = { label = 'Gold Earrings', weight = 5 },
    ['valuable_diamond_earrings'] = { label = 'Diamond Earrings', weight = 6 },

    ['valuable_gold_bar'] = { label = 'Gold Bar', weight = 12000 },
    ['valuable_silver_bar'] = { label = 'Silver Bar', weight = 3000 },
}