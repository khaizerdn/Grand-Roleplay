exports.qbx_core:CreateUseableItem('diving_gear', function(source)
    TriggerClientEvent('qbx_divegear:client:useGear', source)
end)

exports.qbx_core:CreateUseableItem('diving_scubacylinder', function(source)
    local success = lib.callback.await('qbx_divegear:client:fillTank', source)
    if success then
        exports.ox_inventory:RemoveItem(source, 'diving_scubacylinder', 1)
    end
end)