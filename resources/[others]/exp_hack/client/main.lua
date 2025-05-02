local currentlyInGame = false
local passed = false

function StartHack(data, fSuccess, fFail)
    OpenGui(data)
    currentlyInGame = true

    while currentlyInGame do Wait(500) end
    
    if type(fSuccess) == "function" and passed then fSuccess() end
    if type(fFail) == "function" and not passed then fSuccess() end
    
    return passed
end
exports("StartHack", StartHack)

RegisterNetEvent('hacking-minigame:death')
AddEventHandler('hacking-minigame:death', function()
    SendNUIMessage({type = "death"})
end)

RegisterNUICallback('success', function(data, cb)
    passed = true
    currentlyInGame = false
    CloseGui()
    cb('ok')
end)

RegisterNUICallback('failure', function(data, cb)
    passed = false
    currentlyInGame = false
    CloseGui()
    cb('ok')
end)

function OpenGui(data)
    SetNuiFocus(true,true)
    SendNUIMessage({type = "enableui", params = data})
end

function CloseGui()
    SetNuiFocus(false,false)
    SendNUIMessage({type = "closeui"})
end

RegisterNUICallback("GetLocales", function (data, callback)
    callback(LOCALES[LANGUAGE])
end)

-- RegisterCommand("hack", function ()
--     StartHack({
--         rounds = 2,
--         squares = 3
--     })
-- end)