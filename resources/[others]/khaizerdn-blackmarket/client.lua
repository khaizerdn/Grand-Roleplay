Citizen.CreateThread(function()
    for key, shop in pairs(Config.Shops) do
        local pedCfg = shop.ped
        local intCfg = shop
        local icon = intCfg.icon

        -- Load and create ped
        local modelHash = GetHashKey(pedCfg.model)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Wait(100) end

        local ped = CreatePed(4, modelHash, pedCfg.coords.x, pedCfg.coords.y, pedCfg.coords.z, pedCfg.coords.w, false, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        -- Load animation
        RequestAnimDict(pedCfg.animation.dict)
        while not HasAnimDictLoaded(pedCfg.animation.dict) do Wait(100) end
        TaskPlayAnim(ped, pedCfg.animation.dict, pedCfg.animation.clip, 8.0, -8.0, -1, 1, 0, false, false, false)

        -- Interaction logic
        if intCfg.UseTarget then
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'open_' .. shop.shop.name,
                    label = intCfg.labelTarget,
                    distance = intCfg.distanceTarget,
                    icon = icon,
                    onSelect = function()
                        exports.ox_inventory:openInventory('shop', { type = shop.shop.name })
                    end
                }
            })
        else
            lib.points.new({
                coords = intCfg.coords,
                distance = intCfg.distanceZone,
                onEnter = function()
                    lib.showTextUI(intCfg.labelZone)
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                nearby = function()
                    if IsControlJustPressed(0, 38) then
                        exports.ox_inventory:openInventory('shop', { type = shop.shop.name })
                    end
                end
            })
        end
    end
end)
