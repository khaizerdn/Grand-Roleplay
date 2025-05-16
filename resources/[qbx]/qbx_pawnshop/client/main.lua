-- main.lua (client)
local config = require 'config.client'
local sharedConfig = require 'config.shared'

---@alias PawnItem {item: string, price: number}
---@alias MeltingItem {requiredItems: {item: string, amount: number}[], rewards: {item: string, amount: number}[], meltTime: number}
local isMelting = false ---@type boolean
local canTake = false ---@type boolean
local meltTimeSeconds = 0 ---@type number
local pawnZones = {} ---@type table<number, table>

---@param id number
---@param shopConfig {coords: vector3, size: vector3, heading: number, debugPoly: boolean, distance: number}
local function addPawnShop(id, shopConfig)
    -- Delete old zone if it exists
    if pawnZones[id] then
        pawnZones[id]:remove()
        pawnZones[id] = nil
    end

    -- Create the interaction zone
    local zone = lib.zones.sphere({
        coords = shopConfig.coords,
        radius = shopConfig.distance or 1.5,
        debug = shopConfig.debugPoly,
        inside = function()
            if IsControlJustReleased(0, 38) then -- E key
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
                            pawnItems = sharedConfig.pawnItems
                        }
                    }
                }
                if not isMelting then
                    pawnShop[#pawnShop + 1] = {
                        title = locale('info.melt'),
                        description = locale('info.melt_pawn'),
                        event = 'qb-pawnshop:client:openMelt',
                        args = {
                            meltingItems = sharedConfig.meltingItems
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
                    id = 'open_pawnShop',
                    title = locale('info.title'),
                    options = pawnShop
                })
                lib.showContext('open_pawnShop')
            end
        end,
        onEnter = function()
            lib.showTextUI('[E] Open Pawnshop', {
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
    for i = 1, #sharedConfig.pawnLocation do
        local shopConfig = sharedConfig.pawnLocation[i]
        local blip = AddBlipForCoord(shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z)
        SetBlipSprite(blip, 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(locale('info.title'))
        EndTextCommandSetBlipName(blip)

        addPawnShop(i, shopConfig)
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

---@param data {meltingItems: MeltingItem[]}
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
        id = 'open_meltMenu',
        menu = 'open_pawnShop',
        title = locale('info.title'),
        options = meltMenu
    })
    lib.showContext('open_meltMenu')
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

---@param data {pawnItems: PawnItem[]}
RegisterNetEvent('qb-pawnshop:client:openPawn', function(data)
    local inventory = exports.ox_inventory:GetPlayerItems()
    local pawnMenu = {}

    for _, invItem in pairs(inventory) do
        for i = 1, #data.pawnItems do
            if invItem.name == data.pawnItems[i].item then
                pawnMenu[#pawnMenu + 1] = {
                    title = invItem.label,
                    description = locale('info.sell_items', data.pawnItems[i].price),
                    event = 'qb-pawnshop:client:pawnitems',
                    args = {
                        name = invItem.name,
                        amount = invItem.amount
                    }
                }
            end
        end
    end
    lib.registerContext({
        id = 'open_pawnMenu',
        menu = 'open_pawnShop',
        title = locale('info.title'),
        options = pawnMenu
    })
    lib.showContext('open_pawnMenu')
end)