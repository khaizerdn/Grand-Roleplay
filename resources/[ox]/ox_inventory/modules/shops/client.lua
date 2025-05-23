if not lib then return end

local shopTypes = {}
local shops = {}
local createBlip = require 'modules.utils.client'.CreateBlip

for shopType, shopData in pairs(lib.load('data.shops') or {} --[[@as table<string, OxShop>]]) do
    local shop = {
        name = shopData.name,
        groups = shopData.groups or shopData.jobs,
        blip = shopData.blip,
        label = shopData.label,
        icon = shopData.icon
    }

    if shared.target then
        shop.model = shopData.model
        shop.targets = shopData.targets
    else
        shop.locations = shopData.locations
    end

    shopTypes[shopType] = shop
    local blip = shop.blip

    if blip then
        blip.name = ('ox_shop_%s'):format(shopType)
        AddTextEntry(blip.name, shop.name or shopType)
    end
end

local Utils = require 'modules.utils.client'

local function hasShopAccess(shop)
    return not shop.groups or client.hasGroup(shop.groups)
end

local function wipeShops()
    for i = 1, #shops do
        local shop = shops[i]
        if shop.zoneId then
            exports.ox_target:removeZone(shop.zoneId)
            shop.zoneId = nil
        end
        if shop.remove then
            shop:remove()
        end
        if shop.blip then
            RemoveBlip(shop.blip)
        end
    end
    table.wipe(shops)
end

local markerColour = { 30, 150, 30 }

local function refreshShops()
    wipeShops()
    local id = 0

    for shopType, shop in pairs(shopTypes) do
        local blip = shop.blip
        local label = shop.label or locale('open_label', shop.name)

        if shared.target then
            if shop.model then
                if not hasShopAccess(shop) then goto skipLoop end
                exports.ox_target:removeModel(shop.model, shop.name)
                exports.ox_target:addModel(shop.model, {
                    {
                        name = shop.name,
                        icon = shop.icon or '',
                        label = label,
                        onSelect = function()
                            client.openInventory('shop', { type = shopType })
                        end,
                        distance = 2
                    },
                })
            elseif shop.targets then
                for i = 1, #shop.targets do
                    local target = shop.targets[i]
                    local shopid = ('%s-%s'):format(shopType, i)

                    if target.ped then
                        id += 1
                        shops[id] = lib.points.new({
                            coords = target.loc,
                            heading = target.heading,
                            distance = 60,
                            inv = 'shop',
                            invId = i,
                            type = shopType,
                            blip = blip and hasShopAccess(shop) and createBlip(blip, target.loc),
                            ped = target.ped,
                            scenario = target.scenario,
                            label = label,
                            groups = shop.groups,
                            icon = shop.icon or '',
                            iconColor = target.iconColor,
                            onEnter = onEnterShop,
                            onExit = onExitShop,
                            shopDistance = target.distance,
                            useTarget = true
                        })
                    else
                        if not hasShopAccess(shop) then goto nextShop end
                        id += 1
                        shops[id] = {
                            zoneId = Utils.CreateBoxZone(target, {
                                {
                                    name = shopid,
                                    icon = shop.icon or '',
                                    label = label,
                                    groups = shop.groups,
                                    onSelect = function()
                                        client.openInventory('shop', { id = i, type = shopType })
                                    end,
                                    iconColor = target.iconColor,
                                    distance = target.distance
                                }
                            }),
                            blip = blip and createBlip(blip, target.coords)
                        }
                    end
                    ::nextShop::
                end
            end
        elseif shop.locations then
            if not hasShopAccess(shop) then goto skipLoop end
            local shopPrompt = { icon = '' }

            for i = 1, #shop.locations do
                local location = shop.locations[i]
                local coords = type(location) == 'table' and location.coords or location
                id += 1

                shops[id] = lib.points.new(coords, 16, {
                    coords = coords,
                    distance = 16,
                    inv = 'shop',
                    invId = i,
                    type = shopType,
                    marker = markerColour,
                    prompt = {
                        options = shop.icon and { icon = shop.icon } or shopPrompt,
                        message = ('%s %s.'):format(locale('interact_prompt', GetControlInstructionalButton(0, 38, true):sub(3)), label)
                    },
                    nearby = Utils.nearbyMarker,
                    blip = blip and createBlip(blip, coords),
                    label = label,
                    groups = shop.groups,
                    icon = shop.icon or '',
                })
            end
        end

        ::skipLoop::
    end
end

return {
    refreshShops = refreshShops,
    wipeShops = wipeShops,
}