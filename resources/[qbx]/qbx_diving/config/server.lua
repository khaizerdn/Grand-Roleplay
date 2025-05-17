return {
    discordWebhook = 'https://discord.com/api/webhooks/1362338530331725834/cF0N_4Z8ABZTOlUAlin0iLJioCiJ6aqBCEYWgJoop-STy3h2TmbDeOGwhalV5eD_Us_Q', -- Replace nil with your webhook if you chose to use discord logging over ox_lib logging
    coralTypes = {
        {item = 'dendrogyra_coral', maxAmount = math.random(1, 5), price = math.random(100, 200)},
        {item = 'antipatharia_coral', maxAmount = math.random(2, 7), price = math.random(80, 150)},
    },
    priceModifiers = {
        {minAmount = 5,  maxAmount = 10, minPercentage = 85, maxPercentage = 90},
        {minAmount = 11, maxAmount = 15, minPercentage = 75,  maxPercentage = 80},
        {minAmount = 16, minPercentage = 65, maxPercentage = 70},
    },
}