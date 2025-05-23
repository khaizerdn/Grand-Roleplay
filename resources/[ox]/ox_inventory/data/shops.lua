return {
	General = {
		name = '24/7 Supermarket',
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'burger', price = 4 },
			{ name = 'water', price = 1 },
			{ name = 'sprunk', price = 2 },
			{ name = 'cola', price = 2 },
		}, locations = {
			vec3(25.69, -1345.51, 29.5),
			vec3(-3040.93, 585.16, 7.91),
			vec3(-3243.89, 1001.35, 12.83),
			vec3(1729.68, 6416.24, 35.04),
			vec3(1960.31, 3742.17, 32.34),
			vec3(548.13, 2669.41, 42.16),
			vec3(2677.14, 3281.31, 55.24),
			vec3(2555.52, 382.06, 108.62),
			vec3(374.12, 327.8, 103.57),
			vec3(-552.73, -584.57, 34.68)
		}, targets = {
			{ loc = vec3(24.49, -1347.26, 28.5), length = 0.7, width = 0.5, heading = 269.26, minZ = 29.5, maxZ = 29.9, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-3039.0, 584.55, 6.91), length = 0.6, width = 0.5, heading = 16.93, minZ = 7.91, maxZ = 8.31, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-3242.26, 999.95, 11.83), length = 0.6, width = 0.6, heading = 355.51, minZ = 12.83, maxZ = 13.23, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(1727.87, 6415.23, 34.04), length = 0.6, width = 0.6, heading = 245.4, minZ = 35.04, maxZ = 35.44, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(1960.07, 3739.98, 31.34), length = 0.6, width = 0.5, heading = 299.48, minZ = 32.34, maxZ = 32.74, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(549.03, 2671.32, 41.16), length = 0.6, width = 0.5, heading = 99.11, minZ = 42.16, maxZ = 42.56, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(2678.03, 3279.44, 54.24), length = 0.6, width = 0.5, heading = 332.05, minZ = 55.24, maxZ = 55.64, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(2557.2, 380.85, 107.62), length = 0.6, width = 0.5, heading = 359.04, minZ = 108.62, maxZ = 109.02, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(372.53, 326.38, 102.57), length = 0.6, width = 0.5, heading = 259.84, minZ = 103.57, maxZ = 103.97, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
		}
	},

	LTD = {
		name = 'LTD',
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'burger', price = 4 },
			{ name = 'water', price = 1 },
			{ name = 'sprunk', price = 2 },
			{ name = 'cola', price = 2 },
		}, locations = {
			vec3(-47.3, -1756.75, 29.42),
			vec3(-707.32, -914.77, 19.22),
			vec3(1699.26, 4923.54, 42.06),
			vec3(-1821.36, 793.8, 138.11),
			vec3(1163.42, -322.39, 69.21),
			
		}, targets = {
			{ loc = vec3(-46.66, -1757.88, 28.42), length = 0.5, width = 0.5, heading = 54.25, minZ = 42.06, maxZ = 42.46, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-706.17, -913.52, 18.22), length = 0.5, width = 0.5, heading = 85.21, minZ = 42.06, maxZ = 42.46, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(1698.17, 4922.89, 41.06), length = 0.5, width = 0.5, heading = 322.93, minZ = 42.06, maxZ = 42.46, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-1820.22, 794.24, 137.09), length = 0.5, width = 0.5, heading = 137.33, minZ = 42.06, maxZ = 42.46, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(1164.65, -322.64, 68.21), length = 0.5, width = 0.5, heading = 96.99, minZ = 42.06, maxZ = 42.46, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
		}
	},

	Liquor = {
		name = 'Robs Liquor',
		blip = {
			id = 93, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'water', price = 1 },
			{ name = 'sprunk', price = 2 },
			{ name = 'cola', price = 2 },
		}, locations = {
			vec3(1135.808, -982.281, 46.415),
			vec3(-1222.915, -906.983, 12.326),
			vec3(-1487.553, -379.107, 40.163),
			vec3(-2968.243, 390.910, 15.043),
			vec3(1166.024, 2708.930, 38.157),
			vec3(1392.562, 3604.684, 34.980),
			vec3(-1393.18, -606.39, 30.32)
		}, targets = {
			{ loc = vec3(1134.14, -982.51, 45.42), length = 0.5, width = 0.5, heading = 276.9, minZ = 46.4, maxZ = 46.8, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-1221.97, -908.28, 11.33), length = 0.6, width = 0.5, heading = 32.6, minZ = 12.3, maxZ = 12.7, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-1486.3, -378.03, 39.16), length = 0.6, width = 0.5, heading = 136.17, minZ = 40.1, maxZ = 40.5, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-2966.45, 390.92, 14.04), length = 0.7, width = 0.5, heading = 82.55, minZ = 15.0, maxZ = 15.4, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(1165.87, 2710.77, 37.16), length = 0.6, width = 0.5, heading = 177.88, minZ = 38.1, maxZ = 38.5, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(1392.74, 3606.37, 33.98), length = 0.6, width = 0.6, heading = 198.93, minZ = 35.0, maxZ = 35.4, distance = 1.5, ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
		}
	},

	BahamaMamas = {
		name = 'Bahama Mamas',
		blip = {
			id = 93, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'burger', price = 4 },
			{ name = 'water', price = 1 },
			{ name = 'sprunk', price = 2 },
			{ name = 'cola', price = 2 },
		}, locations = {
			vec3(-1393.18, -606.39, 30.32)
		}, targets = {
		
		}
	},

	YouTool = {
		name = 'You Tool',
		blip = {
			id = 402, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'tool_tray', price = 5 },
			{ name = 'tool_digitalscale', price = 30 },
			{ name = 'tool_laptop', price = 1000 },
			{ name = 'tool_herbgrinder', price = 20 },
			{ name = 'tool_rollingpaper', price = 1 },
			{ name = 'container_ziplockbag1', price = 2 },
			{ name = 'container_ziplockbag2', price = 3 },
			{ name = 'container_ziplockbag3', price = 4 },
			{ name = 'container_paperbag', price = 1 },
		}, locations = {
			vec3(2748.0, 3473.0, 55.67)
			-- vec3(342.99, -1298.26, 32.51)
		}, targets = {
			{ loc = vec3(2747.3, 3473.08, 54.67), length = 0.6, width = 3.0, heading = 244.8, minZ = 55.0, maxZ = 56.8, distance = 3.0,  ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
		}
	},

	Ammunation = {
		name = 'Ammunation',
		blip = {
			id = 110, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'ammo-9',        price = 1, metadata = { registered = true }, license = 'weapon' }, -- $0.50 per round (box of 50: ~$25)
			{ name = 'WEAPON_KNIFE',  price = 50,   metadata = { registered = true }, license = 'weapon' }, -- Basic tactical knife
			{ name = 'WEAPON_BAT',    price = 30,   metadata = { registered = true }, license = 'weapon' }, -- Aluminum bat
			{ name = 'WEAPON_PISTOL', price = 450,  metadata = { registered = true }, license = 'weapon' }  -- Standard 9mm (e.g., Glock 17)		
		}, locations = {
			vec3(-662.180, -934.961, 21.829),
			vec3(810.25, -2157.60, 29.62),
			vec3(1693.44, 3760.16, 34.71),
			vec3(-330.24, 6083.88, 31.45),
			vec3(252.63, -50.00, 69.94),
			vec3(22.31, -1106.75, 29.8),
			vec3(2567.69, 294.38, 108.73),
			vec3(-1117.58, 2698.61, 18.55),
			vec3(842.44, -1033.42, 28.19),
			vec3(-543.31, -584.94, 34.68) -- Mall LSGS
		}, targets = {
			{ loc = vec3(-661.7, -933.56, 20.83), length = 0.6, width = 0.5, heading = 166.64, minZ = 21.8, maxZ = 22.2, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(809.63, -2158.99, 28.62), length = 0.6, width = 0.5, heading = 349.59, minZ = 29.6, maxZ = 30.0, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(1692.63, 3761.38, 33.71), length = 0.6, width = 0.5, heading = 218.04, minZ = 34.7, maxZ = 35.1, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-331.2, 6085.37, 30.45), length = 0.6, width = 0.5, heading = 214.84, minZ = 31.4, maxZ = 31.8, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(253.62, -51.06, 68.94), length = 0.6, width = 0.5, heading = 59.47, minZ = 69.9, maxZ = 70.3, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(23.17, -1105.65, 28.8), length = 0.6, width = 0.5, heading = 149.02, minZ = 29.8, maxZ = 30.2, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(2567.29, 292.61, 107.73), length = 0.6, width = 0.5, heading = 341.57, minZ = 108.7, maxZ = 109.1, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(-1118.5, 2700.13, 17.55), length = 0.6, width = 0.5, heading = 209.63, minZ = 18.5, maxZ = 18.9, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
			{ loc = vec3(841.8, -1035.26, 27.19), length = 0.6, width = 0.5, heading = 348.17, minZ = 28.2, maxZ = 28.6, distance = 2.0, ped = `s_m_y_ammucity_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
		}
	},

	CluckinBell = {
		name = "Cluckin' Bell",
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'cluckinbell_burger', price = 7 },
			{ name = 'cluckinbell_hotdog', price = 7 },
			{ name = 'sprunk', price = 2 },
			{ name = 'cola', price = 2 },
			{ name = 'water', price = 1 },
		}, locations = {
			vec3(-584.63, -596.22, 34.68)
		}, targets = {
			{ loc = vec3(-586.55, -596.22, 34.68), length = 0.7, width = 0.5, heading = 271.48, minZ = 29.5, maxZ = 29.9, distance = 1.5, ped = `s_f_y_shop_low`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
		}
	},

	AlDentes = {
		name = "Al Dentes",
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'aldentes_pizzaslice', price = 8 },
			{ name = 'sprunk', price = 2 },
			{ name = 'cola', price = 2 },
			{ name = 'water', price = 1 },
		}, locations = {
			vec3(-584.67, -603.7, 34.68)
		}, targets = {
			{ loc = vec3(-586.5, -603.8, 34.68), length = 0.7, width = 0.5, heading = 267.55, minZ = 29.5, maxZ = 29.9, distance = 1.5, ped = `s_f_y_shop_low`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
		}
	},

	BurgerShot = {
		name = "Burger Shot",
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'burgershot_burger', price = 8 },
			{ name = 'sprunk', price = 2 },
			{ name = 'cola', price = 2 },
			{ name = 'water', price = 1 },
		}, locations = {
			vec3(-584.72, -613.51, 34.68)
		}, targets = {
			{ loc = vec3(-586.48, -613.53, 34.68), length = 0.7, width = 0.5, heading = 270.96, minZ = 29.5, maxZ = 29.9, distance = 1.5, ped = `s_f_y_shop_low`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
		}
	},

	DigitalDen = {
		name = "Digital Den",
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'tool_laptop', price = 1000 },
			{ name = 'phone', price = 700 },
		}, locations = {
			vec3(-528.72, -584.17, 34.68)
		}, targets = {
			{ loc = vec3(-586.48, -613.53, 34.68), length = 0.7, width = 0.5, heading = 270.96, minZ = 29.5, maxZ = 29.9, distance = 1.5, ped = `s_f_y_shop_low`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
		}
	},

	ToolShop = {
		name = 'Tool Shop',
		blip = {
			id = 402, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'tool_tray', price = 5 },
			{ name = 'tool_digitalscale', price = 30 },
			{ name = 'tool_laptop', price = 1000 },
			{ name = 'tool_herbgrinder', price = 20 },
			{ name = 'tool_rollingpaper', price = 1 },
			{ name = 'container_ziplockbag1', price = 2 },
			{ name = 'container_ziplockbag2', price = 3 },
			{ name = 'container_ziplockbag3', price = 4 },
			{ name = 'container_paperbag', price = 1 },
		}, locations = {
			vec3(-308.06, -163.97, 40.42)
		}, targets = {
			{ loc = vec3(-308.19, -163.87, 40.42), length = 0.6, width = 3.0, heading = 231.4, minZ = 55.0, maxZ = 56.8, distance = 3.0,  ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
		}
	},

	SmokeOnTheWater = {
		name = 'Smoke On The Water',
		blip = {
			id = 140, colour = 2, scale = 0.8
		}, inventory = {
			{ name = 'joint', price = 15 },
		}, locations = {
			vec3(-1172.08, -1571.77, 4.66)
		}, targets = {
			{ loc = vec3(-308.19, -163.87, 40.42), length = 0.6, width = 3.0, heading = 231.4, minZ = 55.0, maxZ = 56.8, distance = 3.0,  ped = `mp_m_shopkeep_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
		}
	},


	PoliceArmoury = {
		name = 'Armoury',
		groups = shared.police,
		blip = {
			id = 110, colour = 84, scale = 0.8
		}, inventory = {
			{ name = 'ammo-9',           price = 1 }, -- Bulk 9mm ~ $15/50 rounds
			{ name = 'ammo-rifle',       price = 1 }, -- Bulk 5.56mm ~ $22.50/50 rounds
			{ name = 'WEAPON_FLASHLIGHT',price = 60 },   -- Duty-grade flashlight
			{ name = 'WEAPON_NIGHTSTICK',price = 35 },   -- Monadnock/ASP baton
			{ name = 'WEAPON_PISTOL',    price = 300, metadata = { registered = true, serial = 'POL' }, license = 'weapon' }, -- Glock 17/19 LE pricing
			{ name = 'WEAPON_CARBINERIFLE', price = 650, metadata = { registered = true, serial = 'POL' }, license = 'weapon', grade = 3 }, -- LE M4/AR-15 agency rate
			{ name = 'WEAPON_STUNGUN',   price = 200, metadata = { registered = true, serial = 'POL' } } -- Taser X2 agency pricing
		}, locations = {
			vec3(-546.60, -118.52, 36.93)
		}, targets = {
			{ loc = vec3(-544.87, -117.88, 37.86), length = 0.5, width = 3.0, heading = 112.79, minZ = 30.5, maxZ = 32.0, distance = 1.5, ped = `mp_m_securoguard_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
		}
	},

	Medicine = {
		name = 'Pharmacy',
		-- groups = {
		-- 	['ambulance'] = 0
		-- },
		blip = {
			id = 403, colour = 69, scale = 0.8
		}, inventory = {
			-- { name = 'firstaid', price = 26 },
			{ name = 'bandage', price = 7 }
		}, locations = {
			vec3(-437.92, -324.83, 34.91)
		}, targets = {
			{ loc = vec3(308.58, -596.44, 42.29), length = 0.5, width = 3.0, heading = 18.02, minZ = 30.5, maxZ = 32.0, distance = 1.5, ped = `s_m_m_doctor_01`, scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
		}
	},

	BlackMarketArms_1 = { -- La Fuente Blanca
		name = 'Black Market',
		inventory = {
			{ name = 'WEAPON_COMBATMG',     price = 15000, metadata = { registered = false } },
			{ name = 'WEAPON_PUMPSHOTGUN',  price = 1200,  metadata = { registered = false } },
			{ name = 'WEAPON_BATTLEAXE',    price = 300,   metadata = { registered = false } },
			{ name = 'WEAPON_MOLOTOV',      price = 100,   metadata = { registered = false } },
			{ name = 'WEAPON_PIPEBOMB',     price = 800,   metadata = { registered = false } },
			{ name = 'WEAPON_CARBINERIFLE', price = 2500,  metadata = { registered = false } },
			{ name = 'WEAPON_CROWBAR',      price = 50,    metadata = { registered = false } },
			{ name = 'WEAPON_MACHINEPISTOL',price = 2000,  metadata = { registered = false } },
			{ name = 'WEAPON_COMBATPISTOL', price = 1500,  metadata = { registered = false } },
			{ name = 'WEAPON_HEAVYSNIPER',  price = 18000, metadata = { registered = false } },
			{ name = 'ammo-9',              price = 1.00,  metadata = { registered = false } },
			{ name = 'ammo-heavysniper',    price = 4.00,  metadata = { registered = false } },
			{ name = 'ammo-rifle',          price = 3.00,  metadata = { registered = false } },
			{ name = 'ammo-shotgun',        price = 2.00,  metadata = { registered = false } }	
		},
		locations = {
			vec3(1402.84, 1139.97, 109.75)
		},
		targets = {
			{
				loc = vec3(1402.84, 1139.97, 109.75),
				length = 0.5,
				width = 3.0,
				heading = 90.23,
				minZ = 30.5,
				maxZ = 32.0,
				distance = 6,
				ped = `g_m_y_armgoon_02`,
				scenario = 'WORLD_HUMAN_STAND_IMPATIENT'
			}
		}
	},
	
	
	BlackMarketArms_2 = { -- Marlowe Vineyard
		name = 'Black Market',
		inventory = {
			{ name = 'at_suppressor_light',      price = 1200, metadata = { registered = false } },
			{ name = 'WEAPON_SWITCHBLADE',       price = 300,  metadata = { registered = false } },
			{ name = 'WEAPON_SMG',               price = 3000, metadata = { registered = false } },
			{ name = 'WEAPON_MARKSMANRIFLE',     price = 6000, metadata = { registered = false } },
			{ name = 'WEAPON_STICKYBOMB',        price = 3500, metadata = { registered = false } },
			{ name = 'WEAPON_KNIFE',             price = 150,  metadata = { registered = false } },
			{ name = 'WEAPON_BULLPUPRIFLE',      price = 4000, metadata = { registered = false } },
			{ name = 'WEAPON_MICROSMG',          price = 2200, metadata = { registered = false } },
			{ name = 'WEAPON_PISTOL',            price = 1500, metadata = { registered = false } },
			{ name = 'WEAPON_SNIPERRIFLE',       price = 10000,metadata = { registered = false } },
			{ name = 'ammo-9',                   price = 1.00, metadata = { registered = false } },
			{ name = 'ammo-sniper',              price = 4.00, metadata = { registered = false } },
			{ name = 'ammo-rifle',               price = 3.00, metadata = { registered = false } },
			{ name = 'ammo-45',                  price = 2.00, metadata = { registered = false } }
		},
		locations = {
			vec3(-1869.61, 2058.08, 135.43)
		},
		targets = {
			{
				loc = vec3(-1869.61, 2058.08, 135.43),
				length = 0.5,
				width = 3.0,
				heading = 90.23,
				minZ = 30.5,
				maxZ = 32.0,
				distance = 6,
				ped = `g_m_y_armgoon_02`,
				scenario = 'WORLD_HUMAN_STAND_IMPATIENT'
			}
		}
	},
	

	BlackMarketArms_3 = { -- Playboy Mansion
		name = 'Black Market',
		inventory = {
			{ name = 'WEAPON_APPISTOL',      price = 1800, metadata = { registered = false } },
			{ name = 'WEAPON_SNSPISTOL',     price = 500,  metadata = { registered = false } },
			{ name = 'WEAPON_BAT',           price = 100,  metadata = { registered = false } },
			{ name = 'WEAPON_REVOLVER',      price = 2500, metadata = { registered = false } },
			{ name = 'WEAPON_MINISMG',       price = 2200, metadata = { registered = false } },
			{ name = 'WEAPON_DOUBLEACTION',  price = 300,  metadata = { registered = false } },
			{ name = 'WEAPON_VINTAGEPISTOL', price = 2000, metadata = { registered = false } },
			{ name = 'WEAPON_MACHINEPISTOL', price = 2000, metadata = { registered = false } },
			{ name = 'WEAPON_HEAVYPISTOL',   price = 1800, metadata = { registered = false } },
			{ name = 'WEAPON_FLAREGUN',      price = 500,  metadata = { registered = false } },
			{ name = 'ammo-9',               price = 1.00, metadata = { registered = false } },
			{ name = 'ammo-sniper',          price = 4.00, metadata = { registered = false } },
			{ name = 'ammo-rifle',           price = 3.00, metadata = { registered = false } },
			{ name = 'ammo-45',              price = 2.00, metadata = { registered = false } }
		},
		locations = {
			vec3(-1522.09, 112.39, 50.03)
		},
		targets = {
			{
				loc = vec3(-1522.09, 112.39, 50.03),
				length = 0.5,
				width = 3.0,
				heading = 90.23,
				minZ = 30.5,
				maxZ = 32.0,
				distance = 6,
				ped = `g_m_y_armgoon_02`,
				scenario = 'WORLD_HUMAN_STAND_IMPATIENT'
			}
		}
	},	

	VendingMachineDrinks = {
		name = 'Vending Machine',
		inventory = {
			{ name = 'water', price = 1 },
			{ name = 'cola', price = 2 },
		},
		model = {
			`prop_vend_soda_02`, `prop_vend_fridge01`, `prop_vend_water_01`, `prop_vend_soda_01`
		}
	}
}
