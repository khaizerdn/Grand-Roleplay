local sharedConfig = require 'config.shared'
local clientConfig = require 'config.client'
local interiorShell
DecorationObjects = {}
local properties = {}
local insideProperty = false
local isPropertyRental = false
local interactions
local isConcealing = false
local concealWhitelist = {}
local blips = {}

local function createBlip(apartmentCoords, label)
    local blip = AddBlipForCoord(apartmentCoords.x, apartmentCoords.y, apartmentCoords.z)
    SetBlipSprite(blip, 40)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function prepareKeyMenu()
    local keyholders = lib.callback.await('qbx_properties:callback:requestKeyHolders')
    local config = lib.callback.await('qbx_properties:callback:getKeyholderConfig') -- Fetch maxKeyholders and keyholderFee
    local maxKeyholders = config.maxKeyholders
    local keyholderFee = #keyholders * config.keyholderFee -- Calculate total fee
    local title
    if maxKeyholders == -1 then
        title = locale('menu.keyholders_no_limit') -- No limit case
    elseif isPropertyRental then
        title = locale('menu.keyholders_rental', maxKeyholders, keyholderFee) -- Rental with fee
    else
        title = locale('menu.keyholders_owned', maxKeyholders) -- Owned, no fee
    end
    local options = {
        {
            title = locale('menu.add_keyholder'),
            icon = 'plus',
            arrow = true,
            onSelect = function()
                local insidePlayers = lib.callback.await('qbx_properties:callback:requestPotentialKeyholders')
                local options = {}
                for i = 1, #insidePlayers do
                    options[#options + 1] = {
                        title = insidePlayers[i].name,
                        icon = 'user',
                        arrow = true,
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = insidePlayers[i].name,
                                content = locale('alert.give_keys'),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('qbx_properties:server:addKeyholder', insidePlayers[i].citizenid)
                            end
                        end
                    }
                end
                lib.registerContext({
                    id = 'qbx_properties_insideMenu',
                    title = locale('menu.people_inside'),
                    menu = 'qbx_properties_keyMenu',
                    options = options
                })
                lib.showContext('qbx_properties_insideMenu')
            end
        }
    }
    for i = 1, #keyholders do
        options[#options + 1] = {
            title = keyholders[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = keyholders[i].name,
                    content = locale('alert.want_remove_keys'),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:removeKeyholder', keyholders[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_keyMenu',
        title = title,
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_keyMenu')
end

local function prepareDoorbellMenu()
    local ringers = lib.callback.await('qbx_properties:callback:requestRingers')
    local options = {}
    for i = 1, #ringers do
        options[#options + 1] = {
            title = ringers[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = ringers[i].name,
                    content = locale('alert.want_let_person_in'),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:letRingerIn', ringers[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_doorbellMenu',
        title = locale('menu.doorbell_ringers'),
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_doorbellMenu')
end

local function prepareManageMenu()
    local hasAccess = lib.callback.await('qbx_properties:callback:checkAccess')
    if not hasAccess then exports.qbx_core:Notify(locale('notify.no_access'), 'error') return end
    local options = {
        {
            title = locale('menu.manage_keys'),
            icon = 'key',
            arrow = true,
            onSelect = function()
                prepareKeyMenu()
            end
        },
        {
            title = locale('menu.doorbell'),
            icon = 'bell',
            arrow = true,
            onSelect = function()
                prepareDoorbellMenu()
            end
        },
        {
            title = locale('menu.start_decorating'),
            icon = 'shrimp',
            onSelect = function()
                ToggleDecorating()
            end
        }
    }
    if isPropertyRental then
        options[#options+1] = {
            title = 'Stop Renting',
            icon = 'file-invoice-dollar',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Stop Renting',
                    content = 'Are you sure that you want to stop renting this place?',
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:stopRenting')
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_manageMenu',
        title = locale('menu.manage_property'),
        options = options
    })
    lib.showContext('qbx_properties_manageMenu')
end

local function checkInteractions()
    local interactOptions = {
        ['stash'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.stash') })
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('qbx_properties:server:openStash')
            end
        end,
        ['exit'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.exit') })
            if IsControlJustPressed(0, 38) then
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
                TriggerServerEvent('qbx_properties:server:exitProperty')
            end
            if IsControlJustPressed(0, 47) then
                prepareManageMenu()
            end
        end,
        ['clothing'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.clothing') })
            -- Uncomment this if you want players to change clothes like buying on clothing shop. They will get the clothes for free.
            -- if IsControlJustPressed(0, 47) then
            --     exports['illenium-appearance']:startPlayerCustomization(function(appearance)
            --         if appearance then
            --             TriggerServerEvent("illenium-appearance:server:saveAppearance", appearance)
            --         end
            --     end, {
            --         components = true, componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true, bodyArmor = true, shirts = true, decals = true, jackets = true },
            --         props = true, propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true },
            --         enableExit = true,
            --     })
            -- end
            if IsControlJustPressed(0, 38) then
                TriggerEvent('illenium-appearance:client:openOutfitMenu')
            end
        end,
        ['logout'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.logout') })
            if IsControlJustPressed(0, 38) then
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
                TriggerServerEvent('qbx_properties:server:logoutProperty')
            end
        end,
    }
    CreateThread(function()
        while insideProperty do
            local sleep = 800
            local playerCoords = GetEntityCoords(cache.ped)
            for i = 1, #interactions do
                if #(playerCoords - interactions[i].coords) < 1.5 and not IsDecorating then
                    sleep = 0
                    interactOptions[interactions[i].type](interactions[i].coords)
                end
            end
            Wait(sleep)
        end
    end)
end

local function hideExterior(name)
    local models = clientConfig.exteriorHashs[name]
    if not models then return end
    CreateThread(function()
        while insideProperty do
            for i = 1, #models, 1 do
                EnableExteriorCullModelThisFrame(models[i])
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent('qbx_properties:client:updateInteractions', function(interactionsData, interiorString, isRental)
    DoScreenFadeIn(1000)
    interactions = interactionsData
    insideProperty = true
    isPropertyRental = isRental
    checkInteractions()
    hideExterior(interiorString)
end)

RegisterNetEvent('qbx_properties:client:createInterior', function(interiorHash, interiorCoords)
    lib.requestModel(interiorHash, 2000)
    interiorShell = CreateObjectNoOffset(interiorHash, interiorCoords.x, interiorCoords.y, interiorCoords.z, false, false, false)
    FreezeEntityPosition(interiorShell, true)
    SetModelAsNoLongerNeeded(interiorHash)
end)

RegisterNetEvent('qbx_properties:client:loadDecorations', function(decorations)
    for i = 1, #decorations do
        local decoration = decorations[i]
        lib.requestModel(decoration.model, 5000)
        DecorationObjects[decoration.id] = CreateObjectNoOffset(decoration.model, decoration.coords.x, decoration.coords.y, decoration.coords.z, false, false, false)
        SetEntityCollision(DecorationObjects[decoration.id], true, true)
        FreezeEntityPosition(DecorationObjects[decoration.id], true)
        SetEntityRotation(DecorationObjects[decoration.id], decoration.rotation.x, decoration.rotation.y, decoration.rotation.z, 2, false)
        SetModelAsNoLongerNeeded(decoration.model)
    end
end)

RegisterNetEvent('qbx_properties:client:addDecoration', function(id, hash, coords, rotation)
    lib.requestModel(hash, 5000)
    DecorationObjects[id] = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(DecorationObjects[id], true)
    SetEntityRotation(DecorationObjects[id], rotation.x, rotation.y, rotation.z, 2, false)
    SetModelAsNoLongerNeeded(hash)
end)

RegisterNetEvent('qbx_properties:client:removeDecoration', function(objectId)
    if DoesEntityExist(DecorationObjects[objectId]) then DeleteEntity(DecorationObjects[objectId]) end
    DecorationObjects[objectId] = nil
end)

RegisterNetEvent('qbx_properties:client:unloadProperty', function()
    DoScreenFadeIn(1000)
    insideProperty = false
    if DoesEntityExist(interiorShell) then DeleteEntity(interiorShell) end
    for _, v in pairs(DecorationObjects) do
        if DoesEntityExist(v) then DeleteEntity(v) end
    end
    interiorShell = nil
    DecorationObjects = {}
end)

local function singlePropertyMenu(property, noBackMenu)
    local options = {}
    local isOwner = QBX.PlayerData.citizenid == property.owner
    local isKeyholder = lib.table.contains(json.decode(property.keyholders), QBX.PlayerData.citizenid)

    if (isOwner and not property.is_selling) or isKeyholder then
        options[#options + 1] = {
            title = locale('menu.enter'),
            icon = 'cog',
            arrow = true,
            onSelect = function()
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
            end,
            serverEvent = 'qbx_properties:server:enterProperty',
            args = { id = property.id }
        }
    end

    if isOwner then
        if property.is_selling then
            options[#options + 1] = {
                title = locale('menu.cancel_sell'),
                icon = 'ban',
                arrow = true,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = locale('alert.cancel_sell'),
                        content = string.format(locale('alert.confirm_cancel_sell'), property.property_name),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('qbx_properties:server:cancelSellProperty', property.id)
                    end
                end
            }
        else
            options[#options + 1] = {
                title = locale('menu.sell'),
                icon = 'dollar-sign',
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog(locale('alert.sell_property'), {
                        {type = 'number', label = locale('alert.sell_price'), description = locale('alert.sell_price_description'), required = true, min = 1, icon = 'dollar-sign'}
                    })
                    if input then
                        TriggerServerEvent('qbx_properties:server:sellProperty', property.id, input[1])
                    end
                end
            }
        end
    elseif not property.owner or property.is_selling then
        options[#options + 1] = {
            title = locale('menu.buy'),
            icon = 'dollar-sign',
            arrow = true,
            onSelect = function()
                local price = property.is_selling and property.sell_price or property.price
                local alert = lib.alertDialog({
                    header = string.format(locale('alert.buying'), property.property_name),
                    content = string.format(locale('alert.confirm_buy'), property.property_name, price),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:buyProperty', property.id)
                end
            end
        }
    else
        options[#options + 1] = {
            title = locale('menu.ring_doorbell'),
            icon = 'bell',
            arrow = true,
            serverEvent = 'qbx_properties:server:ringProperty',
            args = { id = property.id }
        }
    end

    local menu = 'qbx_properties_propertiesMenu'
    if noBackMenu then menu = nil end
    lib.registerContext({
        id = 'qbx_properties_propertyMenu',
        title = property.property_name,
        menu = menu,
        options = options
    })
    lib.showContext('qbx_properties_propertyMenu')
end

local function propertyMenu(propertyList, owned)
    local options = {
        {
            title = locale('menu.retrieve_properties'),
            description = locale('menu.show_owned_properties'),
            icon = 'bars',
            onSelect = function()
                propertyMenu(propertyList, true)
            end
        }
    }
    for i = 1, #propertyList do
        if owned and propertyList[i].owner == QBX.PlayerData.citizenid or lib.table.contains(json.decode(propertyList[i].keyholders), QBX.PlayerData.citizenid) then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'Home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        elseif not owned then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'Home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        end
    end
    lib.registerContext({
        id = 'qbx_properties_propertiesMenu',
        title = locale('menu.properties'),
        options = options
    })
    lib.showContext('qbx_properties_propertiesMenu')
end

function PreparePropertyMenu(propertyCoords)
    local propertyList = lib.callback.await('qbx_properties:callback:requestProperties', false, propertyCoords)
    if #propertyList == 1 then
        singlePropertyMenu(propertyList[1], true)
    else
        propertyMenu(propertyList)
    end
end

-- Function to create blips for owned/keyholder properties
local function createPropertyBlips()
    if not QBX.PlayerData or not QBX.PlayerData.citizenid then
        print('Error: QBX.PlayerData.citizenid not available for blip creation')
        return
    end

    for _, blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}

    properties = lib.callback.await('qbx_properties:callback:loadProperties')
    local playerCitizenId = QBX.PlayerData.citizenid
    local isRealtor = QBX.PlayerData.job.name == 'realestate'
    print('Player CitizenID: ' .. tostring(playerCitizenId) .. ', Is Realtor: ' .. tostring(isRealtor))

    local propertyData = lib.callback.await('qbx_properties:callback:requestPropertiesForBlips')
    print('Properties fetched: ' .. json.encode(propertyData))

    for i = 1, #propertyData do
        local property = propertyData[i]
        local isOwner = property.owner == playerCitizenId
        local keyholders = json.decode(property.keyholders) or {}
        local isKeyholder = lib.table.contains(keyholders, playerCitizenId)

        if isOwner or isKeyholder or property.is_selling then
            local coords = json.decode(property.coords)
            local label
            local color
            if isOwner then
                label = property.is_selling and locale('menu.selling_property') or locale('menu.home')
                color = property.is_selling and 5 or 2 -- Yellow (5) if selling, green (2) otherwise
            elseif isKeyholder then
                label = property.property_name
                color = 2 -- Green for keyholders
            elseif isRealtor and property.is_selling then
                label = locale('menu.selling_property')
                color = 5 -- Yellow for realtors when property is for sale
            elseif property.is_selling then
                label = locale('menu.for_sale')
                color = 0 -- White for other players when property is for sale
            end
            if not blips[coords] then
                blips[coords] = createBlip(vec3(coords.x, coords.y, coords.z), label)
                SetBlipColour(blips[coords], color)
                print(string.format('Created blip for %s at %s with label %s and color %d', property.property_name, json.encode(coords), label, color))
            end
        else
            print(string.format('Skipped blip for %s: not owned, keyholder, or for sale', property.property_name))
        end
    end
end
-- Function to refresh properties list
local function refreshProperties()
    properties = lib.callback.await('qbx_properties:callback:loadProperties')
    print('Refreshed properties: ' .. json.encode(properties))
end

-- Wait for player data to be loaded before creating blips
CreateThread(function()
    -- Wait until QBX.PlayerData is available
    while not QBX.PlayerData or not QBX.PlayerData.citizenid do
        Wait(100)
    end

    -- Create blips and load properties initially
    createPropertyBlips()

    -- Interaction loop for properties
    while true do
        local sleep = 800
        local playerCoords = GetEntityCoords(cache.ped)
        for i = 1, #properties do
            if properties[i].xyz and #(playerCoords - properties[i].xyz) < 1.6 then
                sleep = 0
                qbx.drawText3d({ coords = properties[i].xyz, text = locale('drawtext.view_property') })
                if IsControlJustPressed(0, 38) then
                    PreparePropertyMenu(properties[i])
                end
            end
        end
        Wait(sleep)
    end
end)

-- Refresh blips when property ownership changes
RegisterNetEvent('qbx_properties:client:refreshBlips')
AddEventHandler('qbx_properties:client:refreshBlips', function()
    print('Refreshing property blips')
    createPropertyBlips()
end)

RegisterNetEvent('qbx_properties:client:concealPlayers', function(playerIds)
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
    concealWhitelist = playerIds
    if not isConcealing then
        isConcealing = true
        while isConcealing do
            players = GetActivePlayers()
            for i = 1, #players do
                if not lib.table.contains(concealWhitelist, GetPlayerServerId(players[i])) then
                    NetworkConcealPlayer(players[i], true, false)
                end
            end
            Wait(3000)
        end
    end
end)

RegisterNetEvent('qbx_properties:client:revealPlayers', function()
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
    isConcealing = false
end)

RegisterNetEvent('qbx_properties:client:addProperty', function(propertyCoords)
    -- Ensure propertyCoords is in the correct format
    local formattedCoords = { xyz = vec3(propertyCoords.x, propertyCoords.y, propertyCoords.z) }
    if not lib.table.contains(properties, formattedCoords) then
        properties[#properties + 1] = formattedCoords
        print('Added property to client: ' .. json.encode(formattedCoords))
        -- Refresh properties to ensure consistency
        refreshProperties()
    end
end)