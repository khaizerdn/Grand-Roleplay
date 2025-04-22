CreateThread(function()
    local playerPed, weapon

    while true do
        Wait(500) -- Poll less frequently to reduce load

        playerPed = PlayerPedId()
        weapon = GetSelectedPedWeapon(playerPed)

        -- Check if the player is armed (ignores unarmed, fists, etc.)
        if IsPedArmed(playerPed, 6) and weapon ~= `WEAPON_UNARMED` then
            -- While holding a weapon, run per-frame to hide ammo
            while IsPedArmed(playerPed, 6) and weapon ~= `WEAPON_UNARMED` do
                Wait(0)
                DisplayAmmoThisFrame(false)
                HideHudComponentThisFrame(2)   -- Optional: Weapon Icon
                HideHudComponentThisFrame(20)  -- Optional: Weapon Wheel Stats

                -- Update weapon in case player switches quickly
                weapon = GetSelectedPedWeapon(playerPed)
            end
        end
    end
end)
