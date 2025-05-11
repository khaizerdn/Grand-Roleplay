return {
	{
		name = 'crafting_joint',
		items = {
			-- Stage 1: Break bud into bits
			{
				name = 'weed_bits',
				ingredients = {
					weed_bud = 1,
					herb_grinder = 0.01,  -- tool requirement
				},
				duration = 2000,
				count = 2,
			},

			-- Stage 2: Weigh bits into grams
			{
				name = 'weed_gram',
				ingredients = {
					weed_bits = 2,
					digital_scale = 0.01,  -- tool requirement
				},
				duration = 2000,
				count = 1
			},

			-- Stage 3: Roll joint
			{
				name = 'joint',
				ingredients = {
					weed_gram = 1,
					rolling_paper = 1,
					tray = 0.01  -- tool requirement
				},
				duration = 3000,
				count = 1,
			},
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
