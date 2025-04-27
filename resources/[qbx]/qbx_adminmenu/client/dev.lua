local getVector4OnAim = false
local showCoords = false
local vehicleDev = false
local vehicleTypes = {'Compacts', 'Sedans', 'SUVs', 'Coupes', 'Muscle', 'Sports Classics', 'Sports', 'Super', 'Motorcycles', 'Off-road', 'Industrial', 'Utility', 'Vans', 'Cycles', 'Boats', 'Helicopters', 'Planes', 'Service', 'Emergency', 'Military', 'Commercial', 'Trains', 'Open Wheel'}
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
        
                        if IsControlJustPressed(0, 38) then -- 'E' key
                            local x, y, z = qbx.math.round(coords.x, 2), qbx.math.round(coords.y, 2), qbx.math.round(coords.z, 2)
                            local h = qbx.math.round(GetEntityHeading(entity), 2)
                            local data = string.format('vec4(%s, %s, %s, %s)', x, y, z, h)
                            lib.setClipboard(data)
                            exports.qbx_core:Notify('Vector4 copied to clipboard', 'success')
                        end
                    end
                end
            end
        end
    end,
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
        {label = 'Toggle Get Vector4 on Aim', description = 'When enabled, aim at an object or ped with your weapon and press E to copy its vector4', icon = 'fas fa-crosshairs', close = false}
    }
}, function(selected)
    options[selected]()
end)
