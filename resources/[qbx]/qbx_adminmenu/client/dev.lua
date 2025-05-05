-- At the top of dev.lua, after existing variables
local showCoords = false
local vehicleDev = false
local getVector4OnAim = false
local coordinateCapture = false
local vehicleTypes = {'Compacts', 'Sedans', 'SUVs', 'Coupes', 'Muscle', 'Sports Classics', 'Sports', 'Super', 'Motorcycles', 'Off-road', 'Industrial', 'Utility', 'Vans', 'Cycles', 'Boats', 'Helicopters', 'Planes', 'Service', 'Emergency', 'Military', 'Commercial', 'Trains', 'Open Wheel'}

local function toggleCoordinateCaptureNoclip()
    coordinateCapture = not coordinateCapture
    if coordinateCapture then
        exports.qbx_core:Notify('Coordinate capture mode enabled. Left-click for vector3, right-click for vector4, F to lower marker, G to raise marker, C to exit.', 'success')
        local speed = 1.0
        local maxSpeed = 32.0
        local markerOffsetZ = 0.0
        TriggerEvent('qbx_admin:client:ToggleNoClip') -- Enable noclip
        CreateThread(function()
            while coordinateCapture do
                Wait(0)
                -- Adjust noclip speed with mouse wheel
                if IsDisabledControlPressed(2, 17) then -- Scroll Wheel Up
                    speed = math.min(speed + 0.1, maxSpeed)
                elseif IsDisabledControlPressed(2, 16) then -- Scroll Wheel Down
                    speed = math.max(0.1, speed - 0.1)
                end
                -- Update noclip speed (assuming noclip uses a global speed variable)
                -- Note: This requires modifying toggleNoclip in admin.lua to use a global speed
                -- For simplicity, we assume speed is accessible; adjust if necessary
                -- Raycast for marker position
                local camPos = GetGameplayCamCoord()
                local camRot = GetGameplayCamRot(2)
                local forward = vector3(
                    -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                    math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                    math.sin(math.rad(camRot.x))
                )
                local endPos = camPos + forward * 1000.0
                local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, endPos.x, endPos.y, endPos.z, -1, cache.ped, 0)
                local _, hit, hitPos, _, _ = GetShapeTestResult(rayHandle)
                if hit then
                    -- Adjust marker Z position with F (down) and G (up)
                    if IsControlPressed(0, 44) then -- F
                        markerOffsetZ = markerOffsetZ - 0.001
                    elseif IsControlPressed(0, 38) then -- G
                        markerOffsetZ = markerOffsetZ + 0.001
                    end
                    local markerPos = vector3(hitPos.x, hitPos.y, hitPos.z + markerOffsetZ)
                    DrawMarker(25, markerPos.x, markerPos.y, markerPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 1, 41, 128, 185, 100, false, true, 2, nil, nil, false)
                    -- Check for mouse clicks
                    if IsDisabledControlJustPressed(0, 27) then -- Left click
                        local x, y, z = qbx.math.round(markerPos.x, 2), qbx.math.round(markerPos.y, 2), qbx.math.round(markerPos.z, 2)
                        local data = string.format('vec3(%.2f, %.2f, %.2f)', x, y, z)
                        lib.setClipboard(data)
                        exports.qbx_core:Notify('Vector3 copied to clipboard', 'success')
                    end
                    if IsDisabledControlJustPressed(0, 25) then -- Right click
                        local x, y, z = qbx.math.round(markerPos.x, 2), qbx.math.round(markerPos.y, 2), qbx.math.round(markerPos.z, 2)
                        local h = qbx.math.round(camRot.z, 2)
                        local data = string.format('vec4(%.2f, %.2f, %.2f, %.2f)', x, y, z, h)
                        lib.setClipboard(data)
                        exports.qbx_core:Notify('Vector4 copied to clipboard', 'success')
                    end
                end
                -- Check for exit
                if IsControlJustPressed(0, 26) then -- C key
                    coordinateCapture = false
                end
            end
            -- Cleanup
            TriggerEvent('qbx_admin:client:ToggleNoClip') -- Disable noclip
            exports.qbx_core:Notify('Coordinate capture mode disabled.', 'error')
        end)
    end
end

local options = {
    function() CopyToClipboard('coords2') lib.showMenu('qbx_adminmenu_dev_menu', MenuIndexes.qbx_adminmenu_dev_menu) end,
    function() CopyToClipboard('coords3') lib.showMenu('qbx_adminmenu_dev_menu', MenuIndexes.qbx_adminmenu_dev_menu) end,
    function() CopyToClipboard('coords4') lib.showMenu('qbx_adminmenu_dev_menu', MenuIndexes.qbx_adminmenu_dev_menu) end,
    function() CopyToClipboard('heading') lib.showMenu('qbx_adminmenu_dev_menu', MenuIndexes.qbx_adminmenu_dev_menu) end,
    function()
        showCoords = not showCoords
        while showCoords do
            local coords, heading = GetEntityCoords(cache.ped), GetEntityHeading(cache.ped)
            qbx.drawText2d({
                text = ('~o~vector4~w~(%s, %s, %s, %s)'):format(qbx.math.round(coords.x, 2), qbx.math.round(coords.y, 2), qbx.math.round(coords.z, 2), qbx.math.round(heading, 2)),
                coords = vec2(1.0, 0.5),
                scale = 0.5,
                font = 6
            })
            Wait(0)
        end
    end,
    function()
        vehicleDev = not vehicleDev
        while vehicleDev do
            if cache.vehicle then
                local clutch, gear, rpm, temperature = GetVehicleClutch(cache.vehicle), GetVehicleCurrentGear(cache.vehicle), GetVehicleCurrentRpm(cache.vehicle), GetVehicleEngineTemperature(cache.vehicle)
                local oil, angle, body, class = GetVehicleOilLevel(cache.vehicle), GetVehicleSteeringAngle(cache.vehicle), GetVehicleBodyHealth(cache.vehicle), vehicleTypes[GetVehicleClass(cache.vehicle)]
                local dirt, maxSpeed, netId, hash = GetVehicleDirtLevel(cache.vehicle), GetVehicleEstimatedMaxSpeed(cache.vehicle), VehToNet(cache.vehicle), GetEntityModel(cache.vehicle)
                local name = GetLabelText(GetDisplayNameFromVehicleModel(hash))
                qbx.drawText2d({
                    text = ('~o~Clutch: ~w~ %s | ~o~Gear: ~w~ %s | ~o~Rpm: ~w~ %s | ~o~Temperature: ~w~ %s'):format(qbx.math.round(clutch, 4), gear, qbx.math.round(rpm, 4), temperature),
                    coords = vec2(1.0, 0.575),
                    scale = 0.45,
                    font = 6
                })
                qbx.drawText2d({
                    text = ('~o~Oil: ~w~ %s | ~o~Steering Angle: ~w~ %s | ~o~Body: ~w~ %s | ~o~Class: ~w~ %s'):format(qbx.math.round(oil, 4), qbx.math.round(angle, 4), qbx.math.round(body, 4), class),
                    coords = vec2(1.0, 0.600),
                    scale = 0.45,
                    font = 6
                })
                qbx.drawText2d({
                    text = ('~o~Dirt: ~w~ %s | ~o~Est Max Speed: ~w~ %s | ~o~Net ID: ~w~ %s | ~o~Hash: ~w~ %s'):format(qbx.math.round(dirt, 4), qbx.math.round(maxSpeed, 4) * 3.6, netId, hash),
                    coords = vec2(1.0, 0.625),
                    scale = 0.45,
                    font = 6
                })
                qbx.drawText2d({
                    text = ('~o~Vehicle Name: ~w~ %s'):format(name),
                    coords = vec2(1.0, 0.650),
                    scale = 0.45,
                    font = 6
                })
                Wait(0)
            else
                Wait(800)
            end
        end
    end,
    function()
        getVector4OnAim = not getVector4OnAim
        if getVector4OnAim then
            exports.qbx_core:Notify('Get Vector on Aim enabled', 'success')
        else
            exports.qbx_core:Notify('Get Vector on Aim disabled', 'error')
        end
        while getVector4OnAim do
            Wait(0)
            if IsPlayerFreeAiming(PlayerId()) and GetSelectedPedWeapon(cache.ped) ~= `WEAPON_UNARMED` then
                local _, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if entity and DoesEntityExist(entity) and (GetEntityType(entity) == 1 or GetEntityType(entity) == 3) then
                    local min, max = GetModelDimensions(GetEntityModel(entity))
                    local coords = GetEntityCoords(entity)
                    local rotation = GetEntityRotation(entity, 2)
                    local scale = vector3(1.0, 1.0, 1.0)

                    -- Calculate the 8 corners of the bounding box
                    local corners = {
                        coords + rotation * (min * scale),
                        coords + rotation * (vector3(max.x, min.y, min.z) * scale),
                        coords + rotation * (vector3(max.x, max.y, min.z) * scale),
                        coords + rotation * (vector3(min.x, max.y, min.z) * scale),
                        coords + rotation * (vector3(min.x, min.y, max.z) * scale),
                        coords + rotation * (vector3(max.x, min.y, max.z) * scale),
                        coords + rotation * (vector3(max.x, max.y, max.z) * scale),
                        coords + rotation * (vector3(min.x, max.y, max.z) * scale),
                    }

                    -- Draw lines between the corners to form the box
                    for i = 1, 4 do
                        local next = i % 4 + 1
                        DrawLine(corners[i].x, corners[i].y, corners[i].z, corners[next].x, corners[next].y, corners[next].z, 255, 0, 0, 255)
                        DrawLine(corners[i + 4].x, corners[i + 4].y, corners[i + 4].z, corners[next + 4].x, corners[next + 4].y, corners[next + 4].z, 255, 0, 0, 255)
                        DrawLine(corners[i].x, corners[i].y, corners[i].z, corners[i + 4].x, corners[i + 4].y, corners[i + 4].z, 255, 0, 0, 255)
                    end

                    -- Handle 'E' for vector4
                    if IsControlJustPressed(0, 38) then
                        local x, y, z = qbx.math.round(coords.x, 2), qbx.math.round(coords.y, 2), qbx.math.round(coords.z, 2)
                        local h = qbx.math.round(GetEntityHeading(entity), 2)
                        local data = string.format('vec4(%s, %s, %s, %s)', x, y, z, h)
                        lib.setClipboard(data)
                        exports.qbx_core:Notify('Vector4 copied to clipboard', 'success')
                    end

                    -- Handle 'Q' for vector3
                    if IsControlJustPressed(0, 45) then
                        local x, y, z = qbx.math.round(coords.x, 2), qbx.math.round(coords.y, 2), qbx.math.round(coords.z, 2)
                        local data = string.format('vec3(%s, %s, %s)', x, y, z)
                        lib.setClipboard(data)
                        exports.qbx_core:Notify('Vector3 copied to clipboard', 'success')
                    end

                    if IsControlJustPressed(0, 23) then -- F
                        local model = GetEntityModel(entity)
                        lib.setClipboard(tostring(model))
                        exports.qbx_core:Notify('Model ID copied to clipboard: ' .. model, 'success')
                    end
                end
            end
        end
    end,
    function()
        toggleCoordinateCaptureNoclip()
    end
}

lib.registerMenu({
    id = 'qbx_adminmenu_dev_menu',
    title = locale('title.dev_menu'),
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'qbx_adminmenu_main_menu')
    end,
    onSelected = function(selected)
        MenuIndexes.qbx_adminmenu_dev_menu = selected
    end,
    options = {
        {label = locale('dev_options.label1'), description = locale('dev_options.desc1'), icon = 'fas fa-compass'},
        {label = locale('dev_options.label2'), description = locale('dev_options.desc2'), icon = 'fas fa-compass'},
        {label = locale('dev_options.label3'), description = locale('dev_options.desc3'), icon = 'fas fa-compass'},
        {label = locale('dev_options.label4'), description = locale('dev_options.desc4'), icon = 'fas fa-compass'},
        {label = locale('dev_options.label5'), description = locale('dev_options.desc5'), icon = 'fas fa-compass-drafting', close = false},
        {label = locale('dev_options.label6'), description = locale('dev_options.desc6'), icon = 'fas fa-car-side', close = false},
        {label = 'Toggle Get Vector on Aim', description = 'When enabled, aim at an object or ped with your weapon, press E for vector4 or Q for vector3 to copy coordinates', icon = 'fas fa-crosshairs', close = false},
        {label = 'Coordinate Capture Mode', description = 'Enter noclip mode to capture coordinates with a movable marker. Left-click for vector3, right-click for vector4, F/G to adjust marker height, C to exit.', icon = 'fas fa-map-marker-alt', close = false}
    }
}, function(selected)
    options[selected]()
end)