local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentElevator = nil
local isNearElevator = false

-- Utility: Check if job is allowed
local function IsJobAllowed(elevatorConfig)
    if not elevatorConfig.jobrequiered then return true end
    for _, job in ipairs(elevatorConfig.jobs or {}) do
        if PlayerData.job and PlayerData.job.name == job then
            return true
        end
    end
    return false
end

-- QBCore events
RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(job)
    PlayerData.job = job
end)

-- Create zones and handle logic
CreateThread(function()
    for elevatorName, data in pairs(Config.Elevator) do
        if IsJobAllowed(data) then
            for index, location in pairs(data) do
                if type(index) == "number" and location.coords then
                    local coords = vector3(location.coords.x, location.coords.y, location.coords.z)

                    lib.zones.sphere({
                        coords = coords,
                        radius = 2.0,
                        debug = false,
                        onEnter = function()
                            currentElevator = { name = elevatorName, data = data, currentCoords = location.coords }
                            if Config.TextUI then 
                                lib.showTextUI("Press [E] to move to another location.") 
                            end
                            isNearElevator = true
                        end,
                        onExit = function()
                            currentElevator = nil
                            if Config.TextUI then 
                                lib.hideTextUI() 
                            end
                            isNearElevator = false
                        end,
                        inside = function()
                            -- Handle 'E' key press when inside the elevator area
                            if IsControlJustPressed(0, 38) and IsPedOnFoot(PlayerPedId()) then
                                lib.hideTextUI()  -- Hide the text UI
                                local pedCoords = GetEntityCoords(PlayerPedId())
                                local options = {}

                                -- Dynamically create options for available locations in the elevator
                                for otherIndex, otherLoc in pairs(currentElevator.data) do
                                    if type(otherIndex) == "number" then
                                        local otherVec = vector3(otherLoc.coords.x, otherLoc.coords.y, otherLoc.coords.z)
                                        if #(pedCoords - otherVec) > 2.0 then
                                            options[#options + 1] = {
                                                title = otherLoc.label,
                                                description = otherLoc.description,
                                                icon = "fa-solid fa-elevator",
                                                iconColor = "white",
                                                arrow = false,
                                                event = 'khaizerdn_teleport:elevator',
                                                args = otherLoc.coords
                                            }
                                        end
                                    end
                                end

                                -- Show the context menu if options exist
                                if #options > 0 then
                                    lib.registerContext({
                                        id = 'khaizerdn_teleport_' .. currentElevator.name,
                                        title = currentElevator.name,
                                        options = options
                                    })
                                    lib.showContext('khaizerdn_teleport_' .. currentElevator.name)
                                end
                            end
                        end
                    })
                end
            end
        end
    end
end)

-- Elevator teleport handler
RegisterNetEvent('khaizerdn_teleport:elevator', function(coords)
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    SetEntityHeading(ped, coords.w or 0.0)
    Wait(1000)
    DoScreenFadeIn(500)
end)
