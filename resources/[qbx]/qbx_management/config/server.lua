return {
    discordWebhook = 'https://discord.com/api/webhooks/1361715690456744188/Sbu_GLGcvnsd0tauLIvJ2nEw9b482DqheE95sMraae9zNMg4dr8Ur-uWQDGd8MiRbUjR', -- Replace nil with your webhook if you chose to use discord logging over ox_lib logging
    minOnDutyLogTimeMinutes = 30,
    formatDateTime = '%m-%d-%Y %H:%M',

    -- While the config boss menu creation still works, it is recommended to use the runtime export instead.
    ---@alias GroupName string
    ---@type table<GroupName, ZoneInfo>
    menus = {
        lostmc = {
            coords = vec3(983.69, -90.92, 74.85),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 39.68,
            type = 'gang',
        },
        vagos = {
            coords = vec3(351.18, -2054.92, 22.09),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 39.68,
            type = 'gang',
        },
    },
}