local QBCore = exports['qb-core']:GetCoreObject()
local FUEL_DECOR = "_ANDY_FUEL_DECORE_"
local nozzleDropped = false
local holdingNozzle = false
local nozzleInVehicle = false
local nozzle
local rope
local vehicleFueling
local usedPump
local pumpCoords
local wastingFuel = false
local usingCan = false
local nearTank = false

-- Nozzle Z position based on vehicle class.
local nozzleBasedOnClass = {
    0.65, -- Compacts
    0.65, -- Sedans
    0.85, -- SUVs
    0.6, -- Coupes
    0.55, -- Muscle
    0.6, -- Sports Classics
    0.6, -- Sports
    0.55, -- Super
    0.12, -- Motorcycles
    0.8, -- Off-road
    0.7, -- Industrial
    0.6, -- Utility
    0.7, -- Vans
    0.0, -- Cycles
    0.0, -- Boats
    0.0, -- Helicopters
    0.0, -- Planes
    0.6, -- Service
    0.65, -- Emergency
    0.65, -- Military
    0.75, -- Commercial
    0.0 -- Trains
}

-- Setting the electric vehicle config keys to hashes.
for _, vehHash in pairs(config.electricVehicles) do
    config.electricVehicles[vehHash] = vehHash
end

-- Get the fuel of a vehicle, which is set to an entity.
function GetFuel(vehicle)
    if not DecorExistOn(vehicle, FUEL_DECOR) then
        return GetVehicleFuelLevel(vehicle)
    end
    return DecorGetFloat(vehicle, FUEL_DECOR)
end

-- Setting the fuel to the vehicle entity using decor.
function SetFuel(vehicle, fuel)
    if type(fuel) == "number" and fuel >= 0 and fuel <= 100 then
        SetVehicleFuelLevel(vehicle, fuel)
        DecorSetFloat(vehicle, FUEL_DECOR, GetVehicleFuelLevel(vehicle))
    end
end

-- returns pump position if a player is near it.
function nearPump(coords)
    local entity = nil
    for hash in pairs(config.pumpModels) do
        entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.8, hash, true, true, true)
        if entity ~= 0 then break end
    end
    if config.pumpModels[GetEntityModel(entity)] then
        return GetEntityCoords(entity), entity
    end
end

-- used to load the filling manually animation.
function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

-- Used to play the effect of pouring fuel from the nozzle.
function PlayEffect(pdict, pname)
    CreateThread(function()
        local position = GetOffsetFromEntityInWorldCoords(nozzle, 0.0, 0.28, 0.17)
        UseParticleFxAssetNextCall(pdict)
        local pfx = StartParticleFxLoopedAtCoord(pname, position.x, position.y, position.z, 0.0, 0.0, GetEntityHeading(nozzle), 1.0, false, false, false, false)
        Wait(100)
        StopParticleFxLooped(pfx, 0)
    end)
end

-- Getting the vehicle infront if the player.
function vehicleInFront()
    local entity = nil
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(pedCoords.x, pedCoords.y, pedCoords.z - 1.3, offset.x, offset.y, offset.z, 10, ped, 0)
    local A, B, C, D, entity = GetRaycastResult(rayHandle)
    if IsEntityAVehicle(entity) then
        return entity
    end
end

-- Create nozzle, rope and attach them to the player.
function grabNozzleFromPump()
    LoadAnimDict("anim@am_hold_up@male")
    TaskPlayAnim(ped, "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
    Wait(300)
    nozzle = CreateObject(`prop_cs_fuel_nozle`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(nozzle, ped, GetPedBoneIndex(ped, 0x49D9), 0.11, 0.02, 0.02, -80.0, -90.0, 15.0, true, true, false, true, 1, true)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(0)
    end
    RopeLoadTextures()
    while not pump do
        Wait(0)
    end
    rope = AddRope(pump.x, pump.y, pump.z, 0.0, 0.0, 0.0, 3.0, 1, 1000.0, 0.0, 1.0, false, false, false, 1.0, true)
    while not rope do
        Wait(0)
    end
    ActivatePhysics(rope)
    Wait(50)
    local nozzlePos = GetEntityCoords(nozzle)
    nozzlePos = GetOffsetFromEntityInWorldCoords(nozzle, 0.0, -0.033, -0.195)
    AttachEntitiesToRope(rope, pumpHandle, nozzle, pump.x, pump.y, pump.z + 1.45, nozzlePos.x, nozzlePos.y, nozzlePos.z, 5.0, false, false, nil, nil)
    nozzleDropped = false
    holdingNozzle = true
    nozzleInVehicle = false
    vehicleFueling = false
    usedPump = pumpHandle
    SendNUIMessage({
        type = "status",
        status = true
    })
    SendNUIMessage({
        type = "update",
        fuelCost = "0.00",
        fuelTank = "0.00"
    })
end

-- attach the nozzle to the player.
function grabExistingNozzle()
    AttachEntityToEntity(nozzle, ped, GetPedBoneIndex(ped, 0x49D9), 0.11, 0.02, 0.02, -80.0, -90.0, 15.0, true, true, false, true, 1, true)
    nozzleDropped = false
    holdingNozzle = true
    nozzleInVehicle = false
    vehicleFueling = false
end

-- attach nozzle to vehicle.
function putNozzleInVehicle(vehicle, ptankBone, isBike, dontClear, newTankPosition)
    if isBike then
        AttachEntityToEntity(nozzle, vehicle, ptankBone, 0.0 + newTankPosition.x, -0.2 + newTankPosition.y, 0.2 + newTankPosition.z, -80.0, 0.0, 0.0, true, true, false, false, 1, true)
    else
        AttachEntityToEntity(nozzle, vehicle, ptankBone, -0.18 + newTankPosition.x, 0.0 + newTankPosition.y, 0.75 + newTankPosition.z, -125.0, -90.0, -90.0, true, true, false, false, 1, true)
    end
    if not dontClear and IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
        ClearPedTasks(ped)
    end
    nozzleDropped = false
    holdingNozzle = false
    nozzleInVehicle = true
    wastingFuel = false
    vehicleFueling = vehicle
end

-- detach nozzle from everything and hide ui.
function dropNozzle()
    DetachEntity(nozzle, true, true)
    nozzleDropped = true
    holdingNozzle = false
    nozzleInVehicle = false
    vehicleFueling = false
    SendNUIMessage({
        type = "status",
        status = false
    })
end

-- delete nozzle and rope, and hide ui.
function returnNozzleToPump()
    DeleteEntity(nozzle)
    RopeUnloadTextures()
    DeleteRope(rope)
    nozzleDropped = false
    holdingNozzle = false
    nozzleInVehicle = false
    vehicleFueling = false
    SendNUIMessage({
        type = "status",
        status = false
    })
end

-- Get important information.
CreateThread(function()
    while true do
        ped = PlayerPedId()
        pedCoords = GetEntityCoords(ped)
        pump, pumpHandle = nearPump(pedCoords)
        veh = GetVehiclePedIsIn(ped, true)
        Wait(500)
    end
end)

local function vehicleIsFueling()
    local classMultiplier = config.vehicleClasses[GetVehicleClass(vehicleFueling)]
    local cost = 0
    local adjustedFuel = nil
    
    while vehicleFueling do
        local fuel = GetFuel(vehicleFueling)
        if not DoesEntityExist(vehicleFueling) then
            dropNozzle()
            vehicleFueling = false
            break
        end
        
        local newCost = ((2.0 / classMultiplier) * config.fuelCostMultiplier) - math.random(0, 100) / 100
        local playerData = QBCore.Functions.GetPlayerData()
        
        if (playerData.money['bank'] or 0) < cost then
            SendNUIMessage({
                type = "warn"
            })
            vehicleFueling = false
            break
        end

        fuel = fuel + classMultiplier*50
        if fuel < 100 then
            cost = cost + newCost
        end

        if fuel > 100 or fuel == 100 then
            fuel = 100.0
            SetFuel(vehicleFueling, fuel)
            SendNUIMessage({
                type = "update",
                fuelCost = string.format("%.2f", cost),
                fuelTank = string.format("%.2f", fuel)
            })
            vehicleFueling = false
            break
        end

        SetFuel(vehicleFueling, fuel)
        SendNUIMessage({
            type = "update",
            fuelCost = string.format("%.2f", cost),
            fuelTank = string.format("%.2f", fuel)
        })
        Wait(600)
    end
    if cost ~= 0 then
        TriggerServerEvent("ND_Fuel:pay", cost)
        cost = 0
    end
end

-- Refuel the vehicle.
CreateThread(function()
    while true do
        Wait(2000)
        if vehicleFueling then
            vehicleIsFueling()
        end
    end
end)

-- pumping fuel on the groud.
CreateThread(function()
    while true do
        Wait(500)
        if wastingFuel then
            local cost = 0
            while wastingFuel do
                cost = cost + (2.0 * config.fuelCostMultiplier) - math.random(0, 100) / 100
                SendNUIMessage({
                    type = "update",
                    fuelCost = string.format("%.2f", cost),
                    fuelTank = "0.0"
                })
                local playerData = QBCore.Functions.GetPlayerData()
                if (playerData.money['bank'] or 0) < cost then
                    SendNUIMessage({
                        type = "warn"
                    })
                end
                Wait(800)
            end
            if cost ~= 0 then
                TriggerServerEvent("ND_Fuel:pay", cost)
            end
        end
    end
end)

-- Grabbing and returning the nozzle from the pump.
CreateThread(function()
    local wait = 500
    local isShowingPumpText = false
    local currentPumpText = nil
    while true do
        Wait(wait)
        if pump then
            wait = 0
            local text = nil
            if not holdingNozzle and not nozzleInVehicle and not nozzleDropped then
                text = "[E] Grab Nozzle"
            elseif holdingNozzle and not nearTank and pumpHandle == usedPump then
                text = "[E] Return Nozzle"
            end
            if text then
                if not isShowingPumpText or currentPumpText ~= text then
                    lib.showTextUI(text)
                    isShowingPumpText = true
                    currentPumpText = text
                end
                if IsControlJustPressed(0, 51) then
                    lib.hideTextUI()
                    if text == "[E] Grab Nozzle" then
                        grabNozzleFromPump()
                        Wait(1000)
                        ClearPedTasks(ped)
                    elseif text == "[E] Return Nozzle" then
                        LoadAnimDict("anim@am_hold_up@male")
                        TaskPlayAnim(ped, "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                        Wait(300)
                        returnNozzleToPump()
                        Wait(1000)
                        ClearPedTasks(ped)
                    end
                end
            else
                if isShowingPumpText then
                    lib.hideTextUI()
                    isShowingPumpText = false
                    currentPumpText = nil
                end
            end
        else
            wait = 500
            if isShowingPumpText then
                lib.hideTextUI()
                isShowingPumpText = false
                currentPumpText = nil
            end
        end
    end
end)

-- Attaching and taking the nozzle from the vehicle, and dropping the nozzle from the player or vehicle.
CreateThread(function()
    local wait = 500
    local isShowingNozzleText = false
    local currentNozzleText = nil
    while true do
        Wait(wait)
        if holdingNozzle or nozzleInVehicle or nozzleDropped then
            wait = 0

            -- drop the nozzle and remove it if it's far away from the pump.
            if pump then
                pumpCoords = GetEntityCoords(usedPump)
            end
            if nozzle and pumpCoords then
                nozzleLocation = GetEntityCoords(nozzle)
                if #(pumpCoords - pedCoords) < 3.0 then
                    SendNUIMessage({
                        type = "status",
                        status = true
                    })
                else
                    SendNUIMessage({
                        type = "status",
                        status = false
                    })
                end
                if #(nozzleLocation - pumpCoords) > 6.0 then
                    dropNozzle()
                elseif #(pumpCoords - pedCoords) > 100.0 then
                    returnNozzleToPump()
                end
                local text = nil
                if nozzleDropped and #(nozzleLocation - pedCoords) < 1.5 then
                    text = "[E] Grab Nozzle"
                end

                if text then
                    if not isShowingNozzleText or currentNozzleText ~= text then
                        lib.showTextUI(text)
                        isShowingNozzleText = true
                        currentNozzleText = text
                    end
                    if IsControlJustPressed(0, 51) and text == "[E] Grab Nozzle" then
                        LoadAnimDict("anim@mp_snowball")
                        TaskPlayAnim(ped, "anim@mp_snowball", "pickup_snowball", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                        Wait(700)
                        grabExistingNozzle()
                        ClearPedTasks(ped)
                    end
                else
                    -- Will check vehicle-related texts below if no nozzle drop text
                end
            end

            local veh = vehicleInFront()

            -- Animations for manually fueling and effect for spraying fuel.
            if holdingNozzle and nozzle then
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 24, true)
                if IsDisabledControlPressed(0, 24) then
                    if veh and tankPosition and #(pedCoords - tankPosition) < 1.2 then
                        if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                            LoadAnimDict("timetable@gardener@filling_can")
                            TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                        end
                        wastingFuel = false
                        vehicleFueling = veh
                    else
                        if IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                            vehicleFueling = false
                            ClearPedTasks(ped)
                        end
                        if nozzleLocation then
                            wastingFuel = true
                            PlayEffect("core", "veh_trailer_petrol_spray")
                        end
                    end
                else
                    if IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                        vehicleFueling = false
                        ClearPedTasks(ped)
                    end
                    wastingFuel = false
                end
            end

            -- attaching and taking the nozzle from the vehicle.
            if veh then
                local vehClass = GetVehicleClass(veh)
                local zPos = nozzleBasedOnClass[vehClass + 1]
                local isBike = false
                local nozzleModifiedPosition = {
                    x = 0.0,
                    y = 0.0,
                    z = 0.0
                }
                local textModifiedPosition = {
                    x = 0.0,
                    y = 0.0,
                    z = 0.0
                }
                
                if vehClass == 8 and vehClass ~= 13 and not config.electricVehicles[GetHashKey(veh)] then
                    tankBone = GetEntityBoneIndexByName(veh, "petrolcap")
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "petroltank")
                    end
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "engine")
                    end
                    isBike = true
                elseif vehClass ~= 13 and not config.electricVehicles[GetHashKey(veh)] then
                    tankBone = GetEntityBoneIndexByName(veh, "petrolcap")
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "petroltank_l")
                    end
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "hub_lr")
                    end
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "handle_dside_r")
                        nozzleModifiedPosition.x = 0.1
                        nozzleModifiedPosition.y = -0.5
                        nozzleModifiedPosition.z = -0.6
                        textModifiedPosition.x = 0.55
                        textModifiedPosition.y = 0.1
                        textModifiedPosition.z = -0.2
                    end
                end
                tankPosition = GetWorldPositionOfEntityBone(veh, tankBone)
                if tankPosition and #(pedCoords - tankPosition) < 1.2 then
                    local text = nil
                    if not nozzleInVehicle and holdingNozzle then
                        nearTank = true
                        text = "[E] Attach Nozzle "
                    elseif nozzleInVehicle then
                        text = "[E] Grab Nozzle"
                    end
                    if text then
                        if not isShowingNozzleText or currentNozzleText ~= text then
                            lib.showTextUI(text)
                            isShowingNozzleText = true
                            currentNozzleText = text
                        end
                        if IsControlJustPressed(0, 51) then
                            lib.hideTextUI()
                            if text == "[E] Attach Nozzle " then
                                LoadAnimDict("timetable@gardener@filling_can")
                                TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                                Wait(300)
                                putNozzleInVehicle(veh, tankBone, isBike, true, nozzleModifiedPosition)
                                Wait(300)
                                ClearPedTasks(ped)
                            elseif text == "[E] Grab Nozzle" then
                                LoadAnimDict("timetable@gardener@filling_can")
                                TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                                Wait(300)
                                grabExistingNozzle()
                                Wait(300)
                                ClearPedTasks(ped)
                            end
                        end
                    end
                else
                    nearTank = false
                end
            else
                nearTank = false
            end
            if not currentNozzleText and isShowingNozzleText then
                lib.hideTextUI()
                isShowingNozzleText = false
                currentNozzleText = nil
            end
        else
            wait = 500
            if isShowingNozzleText then
                lib.hideTextUI()
                isShowingNozzleText = false
                currentNozzleText = nil
            end
        end
    end
end)

-- refueling using jerry can.
CreateThread(function()
    local wait = 500
    local isShowingJerryCanText = false
    local currentJerryCanText = nil
    while true do
        Wait(wait)
        if GetSelectedPedWeapon(ped) == 883325847 and not holdingNozzle and not nozzleInVehicle then
            wait = 0
            local veh = vehicleInFront()
            if veh then
                local vehClass = GetVehicleClass(veh)
                local zPos = nozzleBasedOnClass[vehClass + 1]
                local can = GetAmmoInPedWeapon(ped, 883325847)
                local distance = 1.2
                
                if vehClass == 8 and vehClass ~= 13 and not config.electricVehicles[GetHashKey(veh)] then
                    tankBone = GetEntityBoneIndexByName(veh, "petroltank")
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "engine")
                    end
                elseif vehClass == 14 and not config.electricVehicles[GetHashKey(veh)] then
                    tankBone = GetEntityBoneIndexByName(veh, "engine")
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "bodyshell")
                    else
                        distance = 2.0
                    end
                elseif vehClass ~= 13 and not config.electricVehicles[GetHashKey(veh)] then
                    tankBone = GetEntityBoneIndexByName(veh, "petroltank_l")
                    if tankBone == -1 then
                        tankBone = GetEntityBoneIndexByName(veh, "hub_lr")
                    end
                end
                tankPosition = GetWorldPositionOfEntityBone(veh, tankBone)
                if tankPosition and #(pedCoords - tankPosition) < distance then
                    local fuel = GetFuel(veh)
                    local text = string.format("%d%% refuel [E]", math.floor(fuel))
                    if not isShowingJerryCanText or currentJerryCanText ~= text then
                        lib.showTextUI(text)
                        isShowingJerryCanText = true
                        currentJerryCanText = text
                    end
                    local ammo = GetAmmoInPedWeapon(ped, 883325847)
                    if IsControlPressed(0, 51) and ammo > 0 then
                        if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                            LoadAnimDict("timetable@gardener@filling_can")
                            TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                        elseif can and DoesEntityExist(veh) then
                            SetPedAmmo(ped, 883325847, ammo - 3)
                            vehicleFueling = veh
                            usingCan = true
                        end
                    else
                        vehicleFueling = false
                        usingCan = false
                        if IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                            ClearPedTasks(ped)
                        end
                    end
                else
                    if isShowingJerryCanText then
                        lib.hideTextUI()
                        isShowingJerryCanText = false
                        currentJerryCanText = nil
                    end
                end
            else
                if isShowingJerryCanText then
                    lib.hideTextUI()
                    isShowingJerryCanText = false
                    currentJerryCanText = nil
                end
            end
        else
            wait = 500
            if isShowingJerryCanText then
                lib.hideTextUI()
                isShowingJerryCanText = false
                currentJerryCanText = nil
            end
        end
    end
end)

-- Create blips for each gas station location.
CreateThread(function()
    for _, coords in pairs(config.blipLocations) do
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 361)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Gas Station")
        EndTextCommandSetBlipName(blip)
    end
end)

-- vehicle fuel consumption.
CreateThread(function()
    while true do
        Wait(3500)
        local pedVeh = GetVehiclePedIsIn(ped)
        local seat = GetPedInVehicleSeat(pedVeh, -1)
        if pedVeh ~= 0 and seat ~= 0 then
            local vehClass = GetVehicleClass(pedVeh)
            if not DecorExistOn(pedVeh, FUEL_DECOR) then
                SetFuel(pedVeh, math.random(200, 800) / 10)
            end
            local fuel = GetFuel(pedVeh)
            if GetIsVehicleEngineRunning(pedVeh) then
                if fuel < 5.0 then
                    DisableControlAction(0, 71)
                    SetVehicleEngineOn(pedVeh, false, true, true)
                end
                SetFuel(pedVeh, fuel - ((GetVehicleCurrentRpm(pedVeh) * config.vehicleClasses[vehClass]) / 1.7))
            end
        end
    end
end)

-- spawn pumps on the map.
CreateThread(function()
    for _, pumps in pairs(config.addPumps) do
        CreateObject(GetHashKey(pumps.hash), pumps.x, pumps.y, pumps.z - 1.0, true, true, true)
    end
end)

-- Register the fuel decor
CreateThread(function()
    DecorRegister(FUEL_DECOR, 1)
end)