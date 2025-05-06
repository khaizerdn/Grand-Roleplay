local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local ElevatorsOptions = {}

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
    PlayerData.job = QBCore.Functions.GetPlayerData().job
end)

Citizen.CreateThread(function()
    local show = false
    while true do
        Citizen.Wait(0)
        local sleep = true
        local ped = PlayerPedId()
        local pedcoords = GetEntityCoords(ped, false)
        local PlayerData = QBCore.Functions.GetPlayerData()
        local index = 1
        for elevatorName, i in pairs(Config.Elevator) do
            for k, v in pairs(i) do
                if type(k) == "number" then
                    local distance = Vdist(pedcoords.x, pedcoords.y, pedcoords.z, v.coords.x, v.coords.y, v.coords.z)
                    if distance <= 2.0 then
                        sleep = false
                        local allowed = true
                        if i.jobrequiered then
                            allowed = false
                            for _, job in pairs(i.jobs) do
                                if job == PlayerData.job.name then
                                    allowed = true
                                    break
                                end
                            end
                        end
                        if allowed then
                            if not show and Config.TextUI then
                                ShowTextUI('Press [E] to move to another location.')
                                show = true
                            end
                            if IsControlJustPressed(0, 38) and IsPedOnFoot(ped) then
                                ElevatorsOptions[index] = {}
                                local optionCount = 0
                                for key, value in pairs(i) do
                                    if key ~= "jobs" and key ~= "jobrequiered" then
                                        local floorDistance = Vdist(pedcoords.x, pedcoords.y, pedcoords.z, value.coords.x, value.coords.y, value.coords.z)
                                        if floorDistance > 2.0 then
                                            optionCount = optionCount + 1
                                            ElevatorsOptions[index][optionCount] = {
                                                title = value.label,
                                                description = value.description,
                                                event = 'estrp-elevators:elevator',
                                                arrow = false,
                                                icon = "fa-solid fa-elevator",
                                                iconColor = "white",
                                                args = value.coords,
                                            }
                                        end
                                    end
                                end
                                if optionCount > 0 then
                                    lib.registerContext({
                                        id = 'estrp-elevators_'..index,
                                        title = elevatorName,
                                        options = ElevatorsOptions[index],
                                    })
                                    lib.showContext('estrp-elevators_'..index)
                                end
                            end
                        else
                            if show and Config.TextUI then
                                HideTextUI()
                                show = false
                            end
                        end
                    end
                end
            end
            index = index + 1
        end
        if sleep then
            if show and Config.TextUI then
                HideTextUI()
                show = false
            end
            Citizen.Wait(1000)
        end
    end
end)

-- Draw markers for elevator locations
Citizen.CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())
        local PlayerData = QBCore.Functions.GetPlayerData()
        for _, i in pairs(Config.Elevator) do
            for k, v in pairs(i) do
                if type(k) == "number" then
                    local allowed = true
                    if i.jobrequiered then
                        allowed = false
                        for _, job in pairs(i.jobs) do
                            if job == PlayerData.job.name then
                                allowed = true
                                break
                            end
                        end
                    end
                    if allowed then
                        local markerPos = v.coords.xyz
                        local dist = #(playerPos - markerPos)
                        if dist < 20.0 then
                            DrawMarker(
                                25,              -- Marker type: vertical arrow
                                markerPos.x, markerPos.y, markerPos.z, -- Position
                                0.0, 0.0, 0.0,   -- Direction (not used for this type)
                                0.0, 0.0, 0.0,   -- Rotation (not used)
                                1.0, 1.0, 1.0,   -- Scale
                                0, 0, 0,    -- RGB color (light blue)
                                100,             -- Alpha (transparency)
                                false,           -- Bob up and down
                                false,           -- Face camera
                                2,               -- Texture dict (default)
                                false,           -- Rotate
                                nil, nil,        -- Texture (none)
                                false            -- Draw on entities
                            )
                        end
                    end
                end
            end
        end
        Citizen.Wait(0) -- Run every frame
    end
end)

RegisterNetEvent('estrp-elevators:elevator')
AddEventHandler('estrp-elevators:elevator', function(coords)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(500)
    lib.progressBar({
        duration = 3500,
        label = 'Loading...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
    })
    while not IsScreenFadedOut() do
        Wait(10)
    end
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    SetEntityHeading(playerPed, coords.w)
    Wait(1000)
    DoScreenFadeIn(500)
end)

function ShowTextUI(msg)
    lib.showTextUI(msg)
end

function HideTextUI()
    lib.hideTextUI()
end