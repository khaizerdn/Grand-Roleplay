local Config = require 'config'

local blips = {}
local zones = {}

-- Draw or update blip by group name
local function updateBlip(group_name, name)
    if blips[group_name] then RemoveBlip(blips[group_name]) end
    local territory = Config.Territories[group_name]
    if not territory then return end

    local label = name or territory.blip.default.name
    local blip = AddBlipForCoord(territory.blip.coords)
    SetBlipSprite(blip, territory.blip.default.sprite)
    SetBlipColour(blip, territory.blip.default.color)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)

    blips[group_name] = blip
end

RegisterNetEvent('hack:syncBlips', function(data)
    for group_name, name in pairs(data) do
        updateBlip(group_name, name)
    end
end)

RegisterNetEvent("hack:cooldownBlocked", function(seconds)
    print(("Received hack:cooldownBlocked with %d seconds remaining"):format(seconds))
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    lib.notify({
        title = "Cooldown",
        description = ("This terminal is on cooldown.\nTime left: %02dh %02dm %02ds"):format(hours, mins, secs),
        type = "error"
    })
end)

RegisterNetEvent("hack:cooldownPassed", function(group_name)
    print("Received hack:cooldownPassed for group_name: " .. group_name)
    print("Starting minigame for terminal: " .. group_name)
    local ped = PlayerPedId()
    local animDict = 'anim@heists@prison_heiststation@cop_reactions'
    local anim = 'cop_b_idle'
    
    print("Requesting animation dictionary: " .. animDict)
    lib.requestAnimDict(animDict)
    TaskPlayAnim(ped, animDict, anim, 2.0, 2.0, -1, 50, 0, false, false, false)
    print("Animation started")

    print("Starting fallouthacking minigame")
    local success = exports.fallouthacking:start(6, 8)
    print("Minigame result: " .. (success and "success" or "failed"))
    ClearPedTasks(ped)
    print("Cleared ped tasks")

    if success then
        print("Opening blip name input dialog")
        local input = lib.inputDialog("Set Blip Name", {
            {type = "input", label = "Blip Name", default = "Territory Uplink"}
        })

        if input and input[1] and input[1] ~= "" then
            print("Sending hack:setBlipName for " .. group_name .. " with name: " .. input[1])
            TriggerServerEvent("hack:setBlipName", group_name, input[1])
        else
            print("Blip name input canceled or invalid")
            lib.notify({ title = "Hack", description = "Invalid or canceled blip name.", type = "inform" })
        end
    else
        print("Minigame failed, showing notification")
        lib.notify({ title = "Hack", description = "Hack failed!", type = "error" })
    end
end)

-- Create zones for each territory
CreateThread(function()
    for group_name, territory in pairs(Config.Territories) do
        zones[group_name] = lib.zones.sphere({
            coords = territory.hackLocation,
            radius = Config.HackRadius,
            debug = false,
            inside = function()
                if IsControlJustReleased(0, 38) then
                    print("E key pressed in zone for " .. group_name)
                    TriggerServerEvent("hack:checkCooldown", group_name)
                end
            end,
            onEnter = function()
                print("Entered zone for " .. group_name)
                lib.showTextUI('[E] Hack Terminal', {
                    icon = 'laptop',
                    position = 'left-center'
                })
            end,
            onExit = function()
                print("Exited zone for " .. group_name)
                lib.hideTextUI()
            end
        })
    end
end)

-- Request blip sync on start
CreateThread(function()
    TriggerServerEvent("hack:requestBlipSync")
end)