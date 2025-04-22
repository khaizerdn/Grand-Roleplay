local safe = {
    enteringCode = false
}

AddEventHandler("ff_shoprobbery:client:enterSafeCode", function(entity, data)
    if not entity.entity or not DoesEntityExist(entity.entity) then
        safe.enteringCode = false
        Debug("Invalid entity for safe code entry: " .. json.encode(entity), DebugTypes.Error)
        return
    end
    if not data or type(data.index) ~= "number" or type(data.netId) ~= "number" then
        safe.enteringCode = false
        Debug("Invalid data for safe code entry: " .. json.encode(data), DebugTypes.Error)
        return
    end

    Debug("Showing safe code input for store " .. data.index, DebugTypes.Info)
    local inputtedCode = lib.inputDialog(locale("prompt.safe.title"), {
        {
            type = 'number',
            label = locale("prompt.safe.input.code.label"),
            description = locale("prompt.safe.input.code.description"),
            icon = 'qrcode',
            required = true
        },
    }, {
        allowCancel = true
    })
    if not inputtedCode then
        safe.enteringCode = false
        Debug("Safe code input cancelled for store " .. data.index, DebugTypes.Info)
        return
    end

    local success = lib.callback.await('ff_shoprobbery:openSafe', false, data.index, string.format("%04d", inputtedCode[1]))
    if success then
        Debug("Safe code correct, opening safe for store " .. data.index, DebugTypes.Info)
        if not openSafe(entity.entity) then
            safe.enteringCode = false
            Debug("Failed to open safe for store " .. data.index, DebugTypes.Error)
            return
        end
        TriggerServerEvent("ff_shoprobbery:server:lootedSafe", data.index, data.netId)
    else
        Notify(locale("error.incorrect_code"), 'error')
        Debug("Incorrect safe code for store " .. data.index, DebugTypes.Error)
    end

    safe.enteringCode = false
end)

function safe.create(safePosition)
    if not safePosition then return false end
    Debug("Creating safe at position: " .. json.encode(safePosition), DebugTypes.Info)
    lib.requestModel(`h4_prop_h4_safe_01a`, 5000) -- Timeout after 5 seconds
    local obj = CreateObject(`h4_prop_h4_safe_01a`, safePosition.x, safePosition.y, safePosition.z, true, false, false)
    local exists = lib.waitFor(function()
        if DoesEntityExist(obj) and NetworkGetEntityOwner(obj) ~= -1 then return true end
    end, 5000) -- Timeout after 5 seconds

    if not exists then
        Debug("Failed to create safe", DebugTypes.Error)
        return false
    end
    SetEntityHeading(obj, safePosition.w - 180.0)
    SetModelAsNoLongerNeeded(`h4_prop_h4_safe_01a`)
    Debug("Safe created with netId: " .. NetworkGetNetworkIdFromEntity(obj), DebugTypes.Info)
    return true, NetworkGetNetworkIdFromEntity(obj)
end

function safe.createInteract(index, netId)
    if not index or type(index) ~= "number" then return end
    if not netId or type(netId) ~= "number" or not NetworkDoesNetworkIdExist(netId) then
        Debug("Invalid netId for safe interaction: " .. tostring(netId), DebugTypes.Error)
        return
    end
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or not DoesEntityExist(entity) then
        Debug("Safe entity does not exist for netId: " .. netId, DebugTypes.Error)
        return
    end

    local entCoords = GetEntityCoords(entity, false)
    Debug("Creating safe interaction for store " .. index .. " at coords: " .. json.encode(entCoords), DebugTypes.Info)
    CreateThread(function()
        while true do
            local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
            if not storeData or not storeData.active or not storeData.hackedNetwork or storeData.openedSafe then
                Debug("Safe interaction thread stopped for store " .. index, DebugTypes.Info)
                lib.hideTextUI()
                break
            end

            local playerCoords = GetEntityCoords(cache.ped, false)
            local distance = #(playerCoords - entCoords)
            if distance < 2.0 and not safe.enteringCode then
                Debug("Player near safe for store " .. index .. " (distance: " .. distance .. ")", DebugTypes.Info)
                lib.showTextUI(locale("interact.safe"), {
                    icon = 'fas fa-lock',
                    position = 'top-left',
                })
                if IsControlJustPressed(0, 38) then -- 'E' key
                    lib.hideTextUI()
                    safe.enteringCode = true
                    Debug("Player pressed E to enter safe code for store " .. index, DebugTypes.Info)
                    TriggerEvent("ff_shoprobbery:client:enterSafeCode", { entity = entity }, { index = index, netId = netId })
                end
                Wait(5)
            else
                lib.hideTextUI()
                Wait(1000)
            end
        end
    end)
end

function openSafe(safeEntity)
    if not safeEntity or not DoesEntityExist(safeEntity) then
        Debug("Invalid safe entity for opening", DebugTypes.Error)
        return false
    end
    Debug("Opening safe", DebugTypes.Info)
    lib.requestModel(`hei_p_m_bag_var22_arm_s`, 5000)
    local safeCoords = GetEntityCoords(safeEntity, false)
    local safeRotation = GetEntityRotation(safeEntity, 2)
    local bag = CreateObject(`hei_p_m_bag_var22_arm_s`, safeCoords.x, safeCoords.y, safeCoords.z, true, false, false)
    local exists = lib.waitFor(function()
        if DoesEntityExist(bag) and NetworkGetEntityOwner(bag) ~= -1 then return true end
    end, 5000)

    if not exists then
        Debug("Failed to create bag for safe scene", DebugTypes.Error)
        return false
    end

    local currentWeapon = GetSelectedPedWeapon(cache.ped)
    RemoveWeaponFromPed(cache.ped, currentWeapon)
    SetModelAsNoLongerNeeded(`hei_p_m_bag_var22_arm_s`)
    local success = safeIdleScene(safeCoords, safeRotation, safeEntity, bag)
    Debug("Safe opening scene completed: " .. tostring(success), DebugTypes.Info)
    return success
end

function safeIdleScene(coords, rotation, safe, bag)
    Debug("Starting safe idle scene", DebugTypes.Info)
    local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(cache.ped, scene, "anim@scripted@heist@ig15_safe_crack@male@", "idle_player", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(safe, scene, "anim@scripted@heist@ig15_safe_crack@male@", "idle_safe", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bag, scene, "anim@scripted@heist@ig15_safe_crack@male@", "idle_bag", 1.0, 1.0, 1)
    NetworkStartSynchronisedScene(scene)
    Wait(10000)
    NetworkStopSynchronisedScene(scene)

    scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(cache.ped, scene, "anim@scripted@heist@ig15_safe_crack@male@", "door_open_player", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(safe, scene, "anim@scripted@heist@ig15_safe_crack@male@", "door_open_safe", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bag, scene, "anim@scripted@heist@ig15_safe_crack@male@", "door_open_bag", 1.0, 1.0, 1)
    NetworkStartSynchronisedScene(scene)
    Wait(2533)
    NetworkStopSynchronisedScene(scene)

    scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(cache.ped, scene, "anim@scripted@heist@ig15_safe_crack@male@", "success_with_stack_bonds_player", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(safe, scene, "anim@scripted@heist@ig15_safe_crack@male@", "success_with_stack_bonds_safe", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bag, scene, "anim@scripted@heist@ig15_safe_crack@male@", "success_with_stack_bonds_bag", 1.0, 1.0, 1)
    NetworkStartSynchronisedScene(scene)
    Wait(1799)
    NetworkStopSynchronisedScene(scene)
    
    DeleteEntity(bag)

    scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(cache.ped, scene, "anim@scripted@heist@ig15_safe_crack@male@", "exit_player", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(safe, scene, "anim@scripted@heist@ig15_safe_crack@male@", "exit_safe", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bag, scene, "anim@scripted@heist@ig15_safe_crack@male@", "exit_bag", 1.0, 1.0, 1)
    NetworkStartSynchronisedScene(scene)
    Wait(666)
    NetworkStopSynchronisedScene(scene)
    Debug("Safe idle scene completed", DebugTypes.Info)
    return true
end

return safe