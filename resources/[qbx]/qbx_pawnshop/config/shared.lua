return {
    DowntownPawn = {
        name = "Downtown Pawn",
        location = {
            coords = vector3(412.34, 314.81, 103.13),
            size = vector3(1.5, 1.8, 2.0),
            heading = 207.0,
            debugPoly = false,
            distance = 3.0
        },
        blip = {
            sprite = 431,
            color = 5,
            scale = 0.7
        },
        items = {
            { item = 'valuable_silver_ring', price = math.random(10, 25) },
            { item = 'valuable_gold_ring', price = math.random(80, 120) },
            { item = 'valuable_diamond_ring', price = math.random(1500, 2200) },
            { item = 'valuable_silver_necklace', price = math.random(25, 60) },
            { item = 'valuable_gold_necklace', price = math.random(200, 400) },
            { item = 'valuable_diamond_necklace', price = math.random(3000, 4505) },
            { item = 'valuable_silver_bracelet', price = math.random(20, 40) },
            { item = 'valuable_gold_bracelet', price = math.random(150, 300) },
            { item = 'valuable_diamond_bracelet', price = math.random(2500, 4000) },
            { item = 'valuable_silver_earrings', price = math.random(15, 30) },
            { item = 'valuable_gold_earrings', price = math.random(100, 180) },
            { item = 'valuable_diamond_earrings', price = math.random(400, 900) },
            { item = 'phone', price = math.random(150, 300) },
            { item = 'tool_laptop', price = math.random(200, 450) },
        },
        enableMelting = true,
        meltingItems = {
            {
                requiredItems = {
                    { item = 'valuable_gold_ring', amount = 4 },
                    { item = 'valuable_gold_necklace', amount = 2 },
                    { item = 'valuable_gold_bracelet', amount = 2 },
                    { item = 'valuable_gold_earrings', amount = 2 },
                },
                rewards = {
                    { item = 'valuable_gold_bar', amount = 1 },
                },
                meltTime = 0
            },
            {
                requiredItems = {
                    { item = 'valuable_silver_ring', amount = 4 },
                    { item = 'valuable_silver_necklace', amount = 2 },
                    { item = 'valuable_silver_bracelet', amount = 2 },
                    { item = 'valuable_silver_earrings', amount = 2 },
                },
                rewards = {
                    { item = 'valuable_silver_bar', amount = 1 },
                },
                meltTime = 0
            },
        }
    },
    SmokeOnTheWater = {
        name = "Smoke On The Water",
        location = {
            coords = vec3(-1169.34, -1572.74, 4.66),
            size = vector3(1.5, 1.8, 2.0),
            heading = 180.0,
            debugPoly = false,
            distance = 1.0
        },
        blip = {
            sprite = 431,
            color = 5,
            scale = 0.8
        },
        items = {
            { item = 'joint', price = math.random(8, 10) },
        },
        enableMelting = false,
        meltingItems = {}
    }
}