-- main.lua (client)
local config = require 'config.client'
local sharedConfig = require 'config.shared'

---@alias PawnItem {item: string, price: number}
---@alias MeltingItem {requiredItems: {item: string, amount: number}[], rewards: {item: string, amount: number}[], meltTime: number}
local isMelting = false ---@type boolean
local canTake = false ---@type boolean
local meltTimeSeconds = 0 ---@type number
local pawnZones = {} ---@type table<string, table>

---@param id string
---@param shopConfig {coords: vector3, size: vector3, heading: number, debugPoly: boolean, distance: number}
---@param shopData table
local function addPawnShop(id, shopConfig, shopData)
    if pawnZones[id] then
        pawnZones[id]:remove()
        pawnZones[id] = nil
    end

    local zone = lib.zones.sphere({
        coords = shopConfig.coords,
        radius = shopConfig.distance or 1.5,
        debug = shopConfig.debugPoly,
        inside = function()
            if IsControlJustReleased(0, 38) then
                lib.hideTextUI()
                if config.useTimes then
                    local gameHour = GetClockHours()
                    if gameHour < config.timeOpen or gameHour > config.timeClosed then
                        exports.qbx_core:Notify(locale('info.pawn_closed', config.timeOpen, config.timeClosed))
                        return
                    end
                end

                local pawnShop = {
                    {
                        title = locale('info.sell'),
                        description = locale('info.sell_pawn'),
                        event = 'qb-pawnshop:client:openPawn',
                        args = {
                            pawnItems = shopData.items,
                            shopId = id,
                            shopName = shopData.name
                        }
                    }
                }
                if shopData.enableMelting and not isMelting then
                    pawnShop[#pawnShop + 1] = {
                        title = locale('info.melt'),
                        description = locale('info.melt_pawn'),
                        event = 'qb-pawnshop:client:openMelt',
                        args = {
                            meltingItems = shopData.meltingItems,
                            shopId = id,
                            shopName = shopData.name
                        }
                    }
                end
                if canTake then
                    pawnShop[#pawnShop + 1] = {
                        title = locale('info.melt_pickup'),
                        serverEvent = 'qb-pawnshop:server:pickupMelted',
                    }
                end
                lib.registerContext({
                    id = 'open_pawnShop_' .. id,
                    title = shopData.name,
                    options = pawnShop
                })
                lib.showContext('open_pawnShop_' .. id)
            end
        end,
        onEnter = function()
            lib.showTextUI('Press [E] to browse ' .. shopData.name .. '.', {
                icon = 'fas fa-ring',
                position = 'left-center'
            })
        end,
        onExit = function()
            lib.hideTextUI()
            lib.hideContext(false)
        end,
    })

    pawnZones[id] = zone
end

CreateThread(function()
    for id, shop in pairs(sharedConfig) do
        local shopConfig = shop.location
        local blip = AddBlipForCoord(shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z)
        SetBlipSprite(blip, 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(shop.name)
        EndTextCommandSetBlipName(blip)

        addPawnShop(id, shopConfig, shop)
    end
end)

---@param pMeltTimeSeconds number
RegisterNetEvent('qb-pawnshop:client:startMelting', function(pMeltTimeSeconds)
    if isMelting then
        return
    end

    isMelting = true
    meltTimeSeconds = pMeltTimeSeconds
    CreateThread(function()
        while isMelting and LocalPlayer.state.isLoggedIn and meltTimeSeconds > 0 do
            meltTimeSeconds = meltTimeSeconds - 1
            Wait(1000)
        end

        canTake = true
        isMelting = false

        if not config.sendMeltingEmail then
            exports.qbx_core:Notify(locale('info.message'), 'success')
            return
        end

        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = locale('info.title'),
            subject = locale('info.subject'),
            message = locale('info.message'),
            button = {}
        })
    end)
end)

RegisterNetEvent('qb-pawnshop:client:resetPickup', function()
    canTake = false
end)

---@param data {meltingItems: MeltingItem[], shopId: string, shopName: string}
RegisterNetEvent('qb-pawnshop:client:openMelt', function(data)
    local inventory = exports.ox_inventory:GetPlayerItems()
    local meltMenu = {}

    for i = 1, #data.meltingItems do
        local meltingItem = data.meltingItems[i]
        local requiredItemsDesc = ""
        local hasAllItems = true
        for _, reqItem in pairs(meltingItem.requiredItems) do
            local hasItem = false
            for _, invItem in pairs(inventory) do
                if invItem.name == reqItem.item and invItem.count >= reqItem.amount then
                    hasItem = true
                    break
                end
            end
            if not hasItem then
                hasAllItems = false
            end
            requiredItemsDesc = requiredItemsDesc .. reqItem.amount .. "x " .. exports.ox_inventory:Items()[reqItem.item].label .. ", "
        end
        local rewardDesc = meltingItem.rewards[1].amount .. "x " .. exports.ox_inventory:Items()[meltingItem.rewards[1].item].label
        meltMenu[#meltMenu + 1] = {
            title = rewardDesc,
            description = locale('info.melt_item', requiredItemsDesc:sub(1, -3)),
            event = hasAllItems and 'qb-pawnshop:client:meltItems' or nil,
            args = hasAllItems and {
                index = i,
                requiredItems = meltingItem.requiredItems,
            } or nil,
            disabled = not hasAllItems
        }
    end
    lib.registerContext({
        id = 'open_meltMenu_' .. data.shopId,
        menu = 'open_pawnShop_' .. data.shopId,
        title = data.shopName,
        options = meltMenu
    })
    lib.showContext('open_meltMenu_' .. data.shopId)
end)

---@param item {name: string, amount: number}
RegisterNetEvent('qb-pawnshop:client:pawnitems', function(item)
    local input = lib.inputDialog(locale('info.title'), {
        {
            type = 'number',
            label = 'amount',
            placeholder = locale('info.max', item.amount)
        }
    })
    if not input then
        exports.qbx_core:Notify(locale('error.negative'), 'error')
        return
    end

    if not input[1] or input[1] <= 0 then return end
    TriggerServerEvent('qb-pawnshop:server:sellPawnItems', item.name, input[1])
end)

---@param data {index: number, requiredItems: {item: string, amount: number}[]}
RegisterNetEvent('qb-pawnshop:client:meltItems', function(data)
    TriggerServerEvent('qb-pawnshop:server:meltItemRemove', data.index, data.requiredItems)
end)

---@param data {pawnItems: PawnItem[], shopId: string, shopName: string}
RegisterNetEvent('qb-pawnshop:client:openPawn', function(data)
    local inventory = exports.ox_inventory:GetPlayerItems()
    local pawnMenu = {}

    for i = 1, #data.pawnItems do
        local pawnItem = data.pawnItems[i]
        local itemLabel = exports.ox_inventory:Items()[pawnItem.item].label
        local itemAmount = 0
        for _, invItem in pairs(inventory) do
            if invItem.name == pawnItem.item then
                itemAmount = invItem.count
                break
            end
        end
        pawnMenu[#pawnMenu + 1] = {
            title = itemLabel,
            description = locale('info.sell_items', pawnItem.price) .. ' (' .. itemAmount .. ' in inventory)',
            event = itemAmount > 0 and 'qb-pawnshop:client:pawnitems' or nil,
            args = itemAmount > 0 and {
                name = pawnItem.item,
                amount = itemAmount
            } or nil,
            disabled = itemAmount == 0
        }
    end
    lib.registerContext({
        id = 'open_pawnMenu_' .. data.shopId,
        menu = 'open_pawnShop_' .. data.shopId,
        title = data.shopName,
        options = pawnMenu
    })
    lib.showContext('open_pawnMenu_' .. data.shopId)
end)