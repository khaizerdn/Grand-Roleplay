return {
	{
		name = 'crafting_joint',
		items = {
			-- Stage 1: Pick buds from plant
			{
				name = 'cannabis_bud',
				ingredients = {
					cannabis_plant = 1,
				},
				duration = 60000,
				count = 120,
			},
			-- Stage 2: Break bud into bits
			{
				name = 'cannabis_ground',
				ingredients = {
					cannabis_bud = 1,
					herb_grinder = 0.001,  -- tool requirement
				},
				duration = 2000,
				count = 2,
			},
			-- Stage 3: Weigh bits into grams
			{
				name = 'cannabis_gram',
				ingredients = {
					cannabis_ground = 3,
					digital_scale = 0.001,  -- tool requirement
				},
				duration = 3000,
				count = 1
			},
			-- Stage 4: Roll joint
			{
				name = 'joint',
				ingredients = {
					cannabis_gram = 1,
					rolling_paper = 1,
					tray = 0.001  -- tool requirement
				},
				duration = 5000,
				count = 1,
			},
			-- TOTAL TIME = 15 Minutes and 40 seconds
			-- TOTAL JOINTS in 1 CANNABIS PLANT = 80
		},
		points = {
			vec3(1392.35, 1134.79, 109.75)
		},
		zones = {
			{
				coords = vec3(1392.35, 1134.79, 109.75),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 315.0,
			}
		},
		-- blip = { id = 566, colour = 31, scale = 0.8 },
	}
}
