local Config = require 'config'

local blip
local isHacked = false

-- Draw or update blip
local function updateBlip(blipData)
    if blip then RemoveBlip(blip) end

    blip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(blip, blipData.sprite)
    SetBlipColour(blip, blipData.color)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.name)
    EndTextCommandSetBlipName(blip)
end

-- Sync blip from server
RegisterNetEvent('hack:syncBlip', function(data)
    isHacked = data ~= nil
    if isHacked then
        updateBlip(data)
    else
        updateBlip(Config.Blip.default)
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
                    local input = lib.inputDialog("Set Blip Style", {
                        {type = "input", label = "Blip Name", default = "Server Uplink"},
                        {type = "number", label = "Sprite ID", default = 521},
                        {type = "number", label = "Color ID", default = 2}
                    })

                    if input then
                        TriggerServerEvent("hack:setBlipData", {
                            name = input[1],
                            sprite = tonumber(input[2]) or 1,
                            color = tonumber(input[3]) or 0
                        })
                        lib.notify({ title = "Hack", description = "Access Granted. Blip Updated.", type = "success" })
                    else
                        lib.notify({ title = "Hack", description = "Canceled blip configuration.", type = "inform" })
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
