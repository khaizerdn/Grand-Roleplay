local Config = require 'config'

local blip
local isHacked = false

-- Draw or update blip
local function updateBlip(name)
    if blip then RemoveBlip(blip) end

    blip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(blip, Config.Blip.default.sprite)
    SetBlipColour(blip, Config.Blip.default.color)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name or Config.Blip.default.name)
    EndTextCommandSetBlipName(blip)
end

-- Sync blip name from server
RegisterNetEvent('hack:syncBlip', function(name)
    isHacked = name ~= nil
    if isHacked then
        updateBlip(name)
    else
        updateBlip(Config.Blip.default.name)
    end
end)

-- Hacking logic
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.HackLocation)

        if dist < Config.HackRadius then
            sleep = 0
            DrawText3D(Config.HackLocation + vector3(0, 0, 1.0), "[E] Hack Terminal")

            if IsControlJustReleased(0, 38) and not isHacked then
                lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions')
                TaskPlayAnim(ped, 'anim@heists@prison_heiststation@cop_reactions', 'cop_b_idle', 2.0, 2.0, -1, 50, 0, false, false, false)

                local success = exports.fallouthacking:start(6, 8)
                ClearPedTasks(ped)

                if success then
                    local input = lib.inputDialog("Set Blip Name", {
                        {type = "input", label = "Blip Name", default = "Server Uplink"}
                    })

                    if input and input[1] and input[1] ~= "" then
                        TriggerServerEvent("hack:setBlipName", input[1])
                        lib.notify({ title = "Hack", description = "Blip name updated!", type = "success" })
                    else
                        lib.notify({ title = "Hack", description = "Invalid or canceled blip name.", type = "inform" })
                    end
                else
                    lib.notify({ title = "Hack", description = "Hack failed!", type = "error" })
                end
            elseif dist < Config.HackRadius and isHacked then
                DrawText3D(Config.HackLocation + vector3(0, 0, 1.0), "System Already Hacked")
            end
        end

        Wait(sleep)
    end
end)

-- Draw 3D Text UI
function DrawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 215)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(x, y)
    end
end

-- Initial sync request
CreateThread(function()
    TriggerServerEvent("hack:requestBlipSync")
end)
