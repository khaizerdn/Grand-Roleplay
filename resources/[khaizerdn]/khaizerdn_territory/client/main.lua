local Config = require 'config'

local blips = {}
local zones = {}

-- Draw or update blip by id
local function updateBlip(id, name)
    if blips[id] then RemoveBlip(blips[id]) end
    local territory = Config.Territories[id]
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

    blips[id] = blip
end

RegisterNetEvent('hack:syncBlips', function(data)
    for id, name in pairs(data) do
        updateBlip(id, name)
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

RegisterNetEvent("hack:cooldownPassed", function(id)
    print("Received hack:cooldownPassed for id: " .. id)
    print("Starting minigame for terminal: " .. id)
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
            print("Sending hack:setBlipName for " .. id .. " with name: " .. input[1])
            TriggerServerEvent("hack:setBlipName", id, input[1])
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
    for id, territory in pairs(Config.Territories) do
        zones[id] = lib.zones.sphere({
            coords = territory.hackLocation,
            radius = Config.HackRadius,
            debug = false,
            inside = function()
                if IsControlJustReleased(0, 38) then
                    print("E key pressed in zone for " .. id)
                    TriggerServerEvent("hack:checkCooldown", id)
                end
            end,
            onEnter = function()
                print("Entered zone for " .. id)
                lib.showTextUI('[E] Hack Terminal', {
                    icon = 'laptop',
                    position = 'left-center'
                })
            end,
            onExit = function()
                print("Exited zone for " .. id)
                lib.hideTextUI()
            end
        })
    end
end)

-- Request blip sync on start
CreateThread(function()
    TriggerServerEvent("hack:requestBlipSync")
end)