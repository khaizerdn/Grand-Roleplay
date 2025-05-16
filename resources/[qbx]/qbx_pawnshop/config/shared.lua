return {
    pawnLocation = {
        {
            coords = vector3(412.34, 314.81, 103.13),
            size = vector3(1.5, 1.8, 2.0),
            heading = 207.0,
            debugPoly = false,
            distance = 3.0
        }
    },
    pawnItems = {
        { item = 'valuable_silver_ring', price = math.random(20, 50) },
        { item = 'valuable_gold_ring', price = math.random(120, 180) },
        { item = 'valuable_diamond_ring', price = math.random(2500, 3500) },
        { item = 'valuable_silver_necklace', price = math.random(50, 100) },
        { item = 'valuable_gold_necklace', price = math.random(300, 500) },
        { item = 'valuable_diamond_necklace', price = math.random(4000, 6000) },
        { item = 'valuable_silver_bracelet', price = math.random(40, 80) },
        { item = 'valuable_gold_bracelet', price = math.random(250, 400) },
        { item = 'valuable_diamond_bracelet', price = math.random(3000, 4500) },
        { item = 'valuable_silver_earrings', price = math.random(30, 60) },
        { item = 'valuable_gold_earrings', price = math.random(150, 250) },
        { item = 'valuable_diamond_earrings', price = math.random(500, 1000) },
    },
    meltingItems = {
        {
            requiredItems = {
                { item = 'valuable_gold_ring', amount = 2 },
                { item = 'valuable_gold_necklace', amount = 1 },
            },
            rewards = {
                { item = 'valuable_gold_bar', amount = 1 },
            },
            meltTime = 0
        },
    }
}