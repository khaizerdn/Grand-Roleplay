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

-- Create zones for each territory
CreateThread(function()
    for group_name, territory in pairs(Config.Territories) do
        zones[group_name] = lib.zones.sphere({
            coords = territory.hackLocation,
            radius = Config.HackRadius,
            debug = false,
            inside = function()
                if IsControlJustReleased(0, 38) then
                    lib.callback('hack:checkCooldown', false, function(result)
                        if result.passed then
                            local ped = PlayerPedId()
                            local animDict = 'anim@heists@prison_heiststation@cop_reactions'
                            local anim = 'cop_b_idle'

                            -- Start progress circle with typing animation
                            if lib.progressCircle({
                                duration = 5000,
                                label = 'Hacking Terminal',
                                position = 'bottom',
                                useWhileDead = false,
                                canCancel = true,
                                disable = { move = true, combat = true },
                                anim = {
                                    dict = animDict,
                                    clip = anim
                                }
                            }) then
                                -- Continue animation during minigame
                                lib.requestAnimDict(animDict)
                                TaskPlayAnim(ped, animDict, anim, 6.0, -6.0, -1, 1, 0, false, false, false)

                                local success = exports.fallouthacking:start(6, 8)

                                if success then
                                    local input = lib.inputDialog('Set Blip Name', {
                                        { type = 'input', label = 'Blip Name', default = 'Your Group Name' }
                                    })
                                    ClearPedTasks(ped) -- Stop animation after input dialog
                                    if input and input[1] and input[1] ~= "" then
                                        TriggerServerEvent('hack:setBlipName', group_name, input[1])
                                        lib.notify({
                                            title = 'Territory Captured',
                                            description = 'Territory has been captured!',
                                            type = 'success'
                                        })
                                    else
                                        lib.notify({
                                            title = 'Invalid',
                                            description = 'Invalid or canceled blip name.',
                                            type = 'inform'
                                        })
                                    end
                                else
                                    ClearPedTasks(ped) -- Stop animation on failure
                                    lib.notify({
                                        title = 'Hack Failed',
                                        description = 'You can do it. Try again!',
                                        type = 'error'
                                    })
                                end
                            else
                                ClearPedTasks(ped) -- Stop animation on cancel
                                lib.notify({
                                    title = 'Hack Canceled',
                                    description = 'You cancel hacking.',
                                    type = 'error'
                                })
                            end
                        else
                            local hours = math.floor(result.remaining / 3600)
                            local mins = math.floor((result.remaining % 3600) / 60)
                            local secs = result.remaining % 60
                            lib.notify({
                                title = 'In Cooldown',
                                description = ('Time left: %02dh %02dm %02ds'):format(hours, mins, secs),
                                type = 'error'
                            })
                        end
                    end, group_name)
                end
            end,
            onEnter = function()
                lib.showTextUI('Press [E] to hack terminal.', {
                    icon = 'laptop',
                    position = 'left-center'
                })
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })
    end
end)

-- Request blip sync on start
CreateThread(function()
    TriggerServerEvent('hack:requestBlipSync')
end)