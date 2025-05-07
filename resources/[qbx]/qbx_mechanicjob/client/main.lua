local config = require 'config.client'
local sharedConfig = require 'config.shared'

VehicleStatus = {}
local inDuty = false
local inStash = false
local inGarage = false
local inPlateZone = false
local currentPlate = nil
local inPrompt = false

-- Exports
local function getVehicleStatusList(plate)
    return VehicleStatus[plate]
end

local function getVehicleStatus(plate, part)
    return VehicleStatus[plate] and VehicleStatus[plate][part]
end

local function setVehicleStatus(plate, part, level)
    TriggerServerEvent("vehiclemod:server:updatePart", plate, part, level)
end

exports('GetVehicleStatusList', getVehicleStatusList)
exports('GetVehicleStatus', getVehicleStatus)
exports('SetVehicleStatus', setVehicleStatus)

-- Functions
local function sendStatusMessage(statusList)
    if not statusList then return end
    local templateStart = '<div class="chat-message normal"><div class="chat-message-body"><strong>{0}:</strong><br><br> '
    local templateEnd = '</div></div>'
    local templateMiddle = '<strong>'.. config.partLabels.engine ..' (engine):</strong> {1} <br><strong>'.. config.partLabels.body ..' (body):</strong> {2} <br><strong>'.. config.partLabels.radiator ..' (radiator):</strong> {3} <br><strong>'.. config.partLabels.axle ..' (axle):</strong> {4}<br><strong>'.. config.partLabels.brakes ..' (brakes):</strong> {5}<br><strong>'.. config.partLabels.clutch ..' (clutch):</strong> {6}<br><strong>'.. config.partLabels.fuel ..' (fuel):</strong> {7}'
    TriggerEvent('chat:addMessage', {
        template = templateStart .. templateMiddle .. templateEnd,
        args = {locale('labels.veh_status'),
            qbx.math.round(statusList.engine) .. "/" .. sharedConfig.maxStatusValues.engine .. " ("..exports.ox_inventory:Items().advancedrepairkit.label..")",
            qbx.math.round(statusList.body) .. "/" .. sharedConfig.maxStatusValues.body .. " ("..exports.ox_inventory:Items()[sharedConfig.repairCost.body].label..")",
            qbx.math.round(statusList.radiator) .. "/" .. sharedConfig.maxStatusValues.radiator .. ".0 ("..exports.ox_inventory:Items()[sharedConfig.repairCost.radiator].label..")",
            qbx.math.round(statusList.axle) .. "/" .. sharedConfig.maxStatusValues.axle .. ".0 ("..exports.ox_inventory:Items()[sharedConfig.repairCost.axle].label..")",
            qbx.math.round(statusList.brakes) .. "/" .. sharedConfig.maxStatusValues.brakes .. ".0 ("..exports.ox_inventory:Items()[sharedConfig.repairCost.brakes].label..")",
            qbx.math.round(statusList.clutch) .. "/" .. sharedConfig.maxStatusValues.clutch .. ".0 ("..exports.ox_inventory:Items()[sharedConfig.repairCost.clutch].label..")",
            qbx.math.round(statusList.fuel) .. "/" .. sharedConfig.maxStatusValues.fuel .. ".0 ("..exports.ox_inventory:Items()[sharedConfig.repairCost.fuel].label..")"
        }
    })
end

local function detachVehicle()
    DoScreenFadeOut(150)
    Wait(150)
    local plate = sharedConfig.plates[currentPlate]
    FreezeEntityPosition(plate.AttachedVehicle, false)
    SetEntityCoords(plate.AttachedVehicle, plate.coords.x, plate.coords.y, plate.coords.z, false, false, false, false)
    SetEntityHeading(plate.AttachedVehicle, plate.coords.w)
    TaskWarpPedIntoVehicle(cache.ped, plate.AttachedVehicle, -1)
    Wait(500)
    DoScreenFadeIn(250)
    plate.AttachedVehicle = nil
    TriggerServerEvent('qb-vehicletuning:server:SetAttachedVehicle', currentPlate, false)
end

local function checkStatus()
    local plate = qbx.getVehiclePlate(sharedConfig.plates[currentPlate].AttachedVehicle)
    sendStatusMessage(VehicleStatus[plate])
end

local function repairPart(part)
    local hasEnough = lib.callback.await('qbx_mechanicjob:server:checkForItems', false, part)
    if not hasEnough then
        local itemName = sharedConfig.repairCostAmount[part].item
        local amountRequired = sharedConfig.repairCostAmount[part].costs
        return exports.qbx_core:Notify(locale('notifications.not_enough', exports.ox_inventory:Items()[itemName].label, amountRequired), 'error')
    end
    exports.scully_emotemenu:playEmoteByCommand('mechanic')
    if lib.progressBar({
        duration = math.random(5000, 10000),
        label = locale('labels.progress_bar', string.lower(config.partLabels[part])),
        canCancel = true,
        disable = { move = true, car = true, combat = true, mouse = false }
    }) then
        exports.scully_emotemenu:cancelEmote()
        local veh = sharedConfig.plates[currentPlate].AttachedVehicle
        local plate = qbx.getVehiclePlate(veh)
        if part == "engine" then
            SetVehicleEngineHealth(veh, sharedConfig.maxStatusValues[part])
            TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", sharedConfig.maxStatusValues[part])
        elseif part == "body" then
            local enhealth = GetVehicleEngineHealth(veh)
            local realFuel = GetVehicleFuelLevel(veh)
            SetVehicleBodyHealth(veh, sharedConfig.maxStatusValues[part])
            TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", sharedConfig.maxStatusValues[part])
            SetVehicleFixed(veh)
            SetVehicleEngineHealth(veh, enhealth)
            if GetVehicleFuelLevel(veh) ~= realFuel then
                SetVehicleFuelLevel(veh, realFuel)
            end
        else
            TriggerServerEvent("vehiclemod:server:updatePart", plate, part, sharedConfig.maxStatusValues[part])
        end
        exports.qbx_core:Notify(locale('notifications.partrep', config.partLabels[part]))
        Wait(250)
        OpenVehicleStatusMenu()
    else
        exports.scully_emotemenu:cancelEmote()
        exports.qbx_core:Notify(locale('notifications.rep_canceled'), "error")
    end
end

local function openPartMenu(data)
    local partName = data.name
    local part = data.parts
    local options = {
        {
            title = partName,
            description = locale('parts_menu.repair_op', exports.ox_inventory:Items()[sharedConfig.repairCostAmount[part].item].label, sharedConfig.repairCostAmount[part].costs),
            onSelect = function()
                repairPart(part)
            end
        }
    }
    lib.registerContext({
        id = 'part',
        title = locale('parts_menu.menu_header'),
        options = options,
        menu = 'vehicleStatus'
    })
    lib.showContext('part')
end

function OpenVehicleStatusMenu()
    local plate = qbx.getVehiclePlate(sharedConfig.plates[currentPlate].AttachedVehicle)
    if not VehicleStatus[plate] then return end
    local options = {}
    for partName, label in pairs(config.partLabels) do
        local percentage = math.ceil(VehicleStatus[plate][partName])
        if percentage > 100 then percentage = percentage / 10 end
        if math.ceil(VehicleStatus[plate][partName]) ~= sharedConfig.maxStatusValues[partName] then
            options[#options+1] = {
                title = label,
                description = locale('parts_menu.status', percentage),
                onSelect = function()
                    openPartMenu({ name = label, parts = partName })
                end,
                arrow = true
            }
        else
            options[#options+1] = {
                title = label,
                description = locale('parts_menu.status', percentage),
                onSelect = OpenVehicleStatusMenu,
                arrow = true
            }
        end
    end

    lib.registerContext({
        id = 'vehicleStatus',
        title = locale('labels.status'),
        options = options
    })
    lib.showContext('vehicleStatus')
end

local function spawnListVehicle(model)
    local netId = lib.callback.await('qbx_mechanicjob:server:spawnVehicle', false, model, sharedConfig.locations.vehicle, true)
    local timeout = 100
    while not NetworkDoesEntityExistWithNetworkId(netId) and timeout > 0 do
        Wait(10)
        timeout -= 1
    end
    local veh = NetworkGetEntityFromNetworkId(netId)
    SetVehicleNumberPlateText(veh, "MECH"..tostring(math.random(1000, 9999)))
    SetVehicleFuelLevel(veh, 100.0)
    TaskWarpPedIntoVehicle(cache.ped, veh, -1)
    TriggerEvent("vehiclekeys:client:SetOwner", qbx.getVehiclePlate(veh))
    SetVehicleEngineOn(veh, true, true, false)
end

local function createBlip()
    local blip = AddBlipForCoord(sharedConfig.locations.exit.x, sharedConfig.locations.exit.y, sharedConfig.locations.exit.z)
    SetBlipSprite(blip, 446)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(locale('labels.job_blip'))
    EndTextCommandSetBlipName(blip)
end

local function uiPrompt(promptType, id)
    if QBX.PlayerData.job.type ~= 'mechanic' then return end
    CreateThread(function()
        while inPrompt do
            Wait(0)
            if IsControlJustReleased(0, 38) then
                if promptType == 'duty' then
                    TriggerServerEvent("QBCore:ToggleDuty")
                    lib.hideTextUI()
                    break
                elseif promptType == 'stash' then
                    if not inStash then return end
                    exports.ox_inventory:openInventory('stash', {id = 'mechanicstash'})
                    lib.hideTextUI()
                    break
                elseif promptType == 'garage' then
                    if not inGarage then return end
                    if cache.vehicle then
                        DeleteVehicle(cache.vehicle)
                        lib.hideTextUI()
                        break
                    else
                        lib.showContext('mechanicVehicles')
                        lib.hideTextUI()
                        break
                    end
                elseif promptType == 'plate' then
                    if not inPlateZone then return end
                    local plate = sharedConfig.plates[id]
                    if plate.AttachedVehicle then
                        lib.showContext('lift')
                        lib.hideTextUI()
                    elseif cache.vehicle then
                        DoScreenFadeOut(150)
                        Wait(150)
                        plate.AttachedVehicle = cache.vehicle
                        SetEntityCoords(cache.vehicle, plate.coords.x, plate.coords.y, plate.coords.z, false, false, false, false)
                        SetEntityHeading(cache.vehicle, plate.coords.w)
                        FreezeEntityPosition(cache.vehicle, true)
                        Wait(500)
                        DoScreenFadeIn(150)
                        TriggerServerEvent('qb-vehicletuning:server:SetAttachedVehicle', id, cache.vehicle)
                        lib.hideTextUI()
                    end
                    break
                end
            end
        end
    end)
end

-- Zones
CreateThread(function()
    -- Duty
    lib.zones.box({
        coords = sharedConfig.locations.duty,
        size = vec3(2, 2, 2),
        rotation = 338.16,
        debug = config.debugPoly,
        onEnter = function()
            if QBX.PlayerData.job.type ~= 'mechanic' then return end
            inDuty = true
            inPrompt = true
            lib.showTextUI(locale(QBX.PlayerData.job.onduty and 'labels.sign_off' or 'labels.sign_in'))
            uiPrompt('duty')
        end,
        onExit = function()
            inDuty = false
            inPrompt = false
            lib.hideTextUI()
        end
    })

    -- Stash
    lib.zones.box({
        coords = sharedConfig.locations.stash,
        size = vec3(1.5, 1.5, 2),
        rotation = 248.41,
        debug = config.debugPoly,
        onEnter = function()
            if QBX.PlayerData.job.type ~= 'mechanic' or not QBX.PlayerData.job.onduty then return end
            inStash = true
            inPrompt = true
            lib.showTextUI(locale('labels.o_stash'))
            uiPrompt('stash')
        end,
        onExit = function()
            inStash = false
            inPrompt = false
            lib.hideTextUI()
        end
    })

    -- Garage
    lib.zones.box({
        coords = sharedConfig.locations.vehicle.xyz,
        size = vec3(15, 5, 6),
        rotation = 340.0,
        debug = config.debugPoly,
        onEnter = function()
            if QBX.PlayerData.job.type ~= 'mechanic' or not QBX.PlayerData.job.onduty then return end
            inGarage = true
            inPrompt = true
            lib.showTextUI(locale(cache.vehicle and 'labels.h_vehicle' or 'labels.g_vehicle'))
            uiPrompt('garage')
        end,
        onExit = function()
            inGarage = false
            inPrompt = false
            lib.hideTextUI()
        end
    })

    -- Vehicle Plates
    for i = 1, #sharedConfig.plates do
        local plate = sharedConfig.plates[i]
        lib.zones.box({
            coords = plate.coords.xyz,
            size = vec3(plate.boxData.width, plate.boxData.length, 4),
            rotation = plate.boxData.heading,
            debug = plate.boxData.debugPoly,
            onEnter = function()
                if not QBX.PlayerData.job.onduty then return end
                inPlateZone = true
                inPrompt = true
                currentPlate = i
                if plate.AttachedVehicle then
                    lib.showTextUI(locale('labels.o_menu'))
                elseif cache.vehicle then
                    lib.showTextUI(locale('labels.work_v'))
                end
                uiPrompt('plate', i)
            end,
            onExit = function()
                inPlateZone = false
                inPrompt = false
                currentPlate = nil
                lib.hideTextUI()
            end
        })
    end
end)

-- Events
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    createBlip()
    lib.callback('qb-vehicletuning:server:GetAttachedVehicle', false, function(plates)
        for k, v in pairs(plates) do
            sharedConfig.plates[k].AttachedVehicle = v.AttachedVehicle
        end
    end)
    lib.callback('qb-vehicletuning:server:GetDrivingDistances', false, function(retval)
        DrivingDistance = retval
    end)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    createBlip()
    lib.callback('qb-vehicletuning:server:GetAttachedVehicle', false, function(plates)
        for k, v in pairs(plates) do
            sharedConfig.plates[k].AttachedVehicle = v.AttachedVehicle
        end
    end)
    lib.callback('qb-vehicletuning:server:GetDrivingDistances', false, function(retval)
        DrivingDistance = retval
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    if QBX.PlayerData.job.type ~= 'mechanic' then
        inDuty = false
        inStash = false
        inPrompt = false
        lib.hideTextUI()
    end
end)

RegisterNetEvent('QBCore:Client:SetDuty', function()
    if QBX.PlayerData.job.type ~= 'mechanic' or not QBX.PlayerData.job.onduty then
        inStash = false
        inPrompt = false
        lib.hideTextUI()
    end
end)

RegisterNetEvent('qb-vehicletuning:client:SetAttachedVehicle', function(veh, key)
    sharedConfig.plates[key].AttachedVehicle = veh
end)

RegisterNetEvent('vehiclemod:client:setVehicleStatus', function(plate, status)
    VehicleStatus[plate] = status
end)

RegisterNetEvent('vehiclemod:client:fixEverything', function()
    local veh = cache.vehicle
    if not veh then
        exports.qbx_core:Notify(locale('notifications.not_vehicle'), "error")
        return
    end
    if IsThisModelABicycle(GetEntityModel(veh)) or cache.seat ~= -1 then
        exports.qbx_core:Notify(locale('notifications.wrong_seat'), "error")
        return
    end
    local plate = qbx.getVehiclePlate(veh)
    TriggerServerEvent("vehiclemod:server:fixEverything", plate)
end)

RegisterNetEvent('vehiclemod:client:setPartLevel', function(part, level)
    local veh = cache.vehicle
    if not veh then
        exports.qbx_core:Notify(locale('notifications.not_vehicle'), "error")
        return
    end
    if IsThisModelABicycle(GetEntityModel(veh)) or cache.seat ~= -1 then
        exports.qbx_core:Notify(locale('notifications.wrong_seat'), "error")
        return
    end
    local plate = qbx.getVehiclePlate(veh)
    if part == "engine" then
        SetVehicleEngineHealth(veh, level)
        TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", GetVehicleEngineHealth(veh))
    elseif part == "body" then
        SetVehicleBodyHealth(veh, level)
        TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", GetVehicleBodyHealth(veh))
    else
        TriggerServerEvent("vehiclemod:server:updatePart", plate, part, level)
    end
end)

AddEventHandler('qb-mechanicjob:client:target:OpenStash', function()
    exports.ox_inventory:openInventory('stash', {id = 'mechanicstash'})
end)

-- Static menus
local function registerLiftMenu()
    lib.registerContext({
        id = 'lift',
        title = locale('lift_menu.header_menu'),
        onExit = function()
            if currentPlate then
                local plate = sharedConfig.plates[currentPlate]
                if plate.AttachedVehicle then
                    lib.showTextUI(locale('labels.o_menu'))
                    inPrompt = true
                    uiPrompt('plate', currentPlate)
                end
            end
        end,
        options = {
            {
                title = locale('lift_menu.header_vehdc'),
                description = locale('lift_menu.desc_vehdc'),
                onSelect = detachVehicle
            },
            {
                title = locale('lift_menu.header_stats'),
                description = locale('lift_menu.desc_stats'),
                onSelect = checkStatus
            },
            {
                title = locale('lift_menu.header_parts'),
                description = locale('lift_menu.desc_parts'),
                arrow = true,
                onSelect = OpenVehicleStatusMenu
            }
        }
    })
end

local function registerVehicleListMenu()
    local options = {}
    for k, v in pairs(config.vehicles) do
        options[#options + 1] = {
            title = v,
            description = locale('labels.vehicle_title', v),
            onSelect = function()
                spawnListVehicle(k)
            end
        }
    end
    lib.registerContext({
        id = 'mechanicVehicles',
        title = locale('labels.vehicle_list'),
        options = options
    })
end

registerLiftMenu()
registerVehicleListMenu()