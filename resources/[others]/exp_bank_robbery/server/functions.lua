function GetPoliceCount()
    local count = 0
    for _, sid in ipairs(SD.GetPlayers()) do
        if SD.HasGroup(source, POLICE_JOBS) then
            count = count + 1
        end
    end
    return count
end

function DiscordLog(player_src, event)
    SD.Logger.Log(player_src, event.name, event.message)
end

function DoesPlayerHaveItem(player_src, item)
    SD.Inventory.HasItem(player_src, item)
end