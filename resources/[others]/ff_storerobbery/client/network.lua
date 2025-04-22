local lastAlert = nil
local network = {
    hackingInteract = false
}

AddEventHandler("ff_shoprobbery:client:hackNetwork", function(_, data)
    if not data or type(data.index) ~= "number" then
        network.hackingInteract = false
        Debug("Invalid data for hackNetwork: " .. json.encode(data), DebugTypes.Error)
        return
    end
    
    Debug("Starting network hack for store " .. data.index, DebugTypes.Info)
    lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions')
    TaskPlayAnim(cache.ped, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 2.0, 2.0, -1, 50, 0, false, false, false)
    
    local hackedNetwork = exports.fallouthacking:start(6, 8)
    if hackedNetwork then
        Debug("Network hack successful for store " .. data.index, DebugTypes.Info)
        local success, safeCode = lib.callback.await('ff_shoprobbery:getSafeCode', false, data.index)
        if not success then
            network.hackingInteract = false
            Debug("Failed to get safe code for store " .. data.index, DebugTypes.Error)
            return
        end
        Notify(string.format(locale("notification.safe_code"), safeCode), "inform", 20000)
    else
        Debug("Network hack failed for store " .. data.index, DebugTypes.Info)
        if not lastAlert or GetGameTimer() > lastAlert then
            NetworkAlert(GetEntityCoords(cache.ped, false))
            lastAlert = GetGameTimer() + Config.NetworkAlertTimeout * 1000
        end
    end
    
    network.hackingInteract = false
    ClearPedTasks(cache.ped)
    Debug("Network hack completed for store " .. data.index, DebugTypes.Info)
end)

function network.createInteract(index)
    if not index or type(index) ~= "number" then return end
    local coords = Config.Locations[index].network.coords
    Debug("Creating hacking interaction for store " .. index .. " at coords: " .. json.encode(coords), DebugTypes.Info)

    CreateThread(function()
        while true do
            local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
            if not storeData or not storeData.active or not storeData.robbedTill or storeData.hackedNetwork then
                Debug("Network interaction thread stopped for store " .. index, DebugTypes.Info)
                lib.hideTextUI()
                break
            end

            local playerCoords = GetEntityCoords(cache.ped, false)
            local distance = #(playerCoords - coords)
            if distance < 2.0 and not network.hackingInteract then
                Debug("Player near network for store " .. index .. " (distance: " .. distance .. ")", DebugTypes.Info)
                lib.showTextUI(locale('interact.network'), {
                    icon = 'fas fa-network-wired',
                    position = 'top-left',
                })
                if IsControlJustPressed(0, 38) then -- 'E' key
                    lib.hideTextUI()
                    network.hackingInteract = true
                    Debug("Player pressed E to hack network for store " .. index, DebugTypes.Info)
                    TriggerEvent("ff_shoprobbery:client:hackNetwork", nil, { index = index })
                end
                Wait(5)
            else
                lib.hideTextUI()
                Wait(1000)
            end
        end
    end)
end

return network