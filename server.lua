ESX = exports["es_extended"]:getSharedObject()




CreateThread(function()
    for k,v in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if Player(v).state.moritz_PlayerIsCuffed then
            Player(v).state.moritz_PlayerIsCuffed = false
        end
        if Player(v).state.moritz_HaveOpenedInventory then
            Player(v).state.moritz_HaveOpenedInventory = false
        end
        if Player(v).state.moritz_PlayerIsDragged then
            Player(v).state.moritz_PlayerIsDragged = false
        end
        if Player(v).state.moritz_PlayerDraggingSomeone then
            Player(v).state.moritz_PlayerDraggingSomeone = false
        end
    end
end)


RegisterNetEvent("moritz_handcuffs:cuffPlayer", function(target, playerheading, coords, playerlocation)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local targetPed = GetPlayerPed(target)

    if not DoesEntityExist(targetPed) then
        TriggerClientEvent('moritz_notify_handcuff',"Du kannst niemand fesseln")
        return
    end

    local targetCoords = GetEntityCoords(targetPed)
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local distance = #(targetCoords-localCoords)

    if distance > 3.0 then
        TriggerClientEvent('moritz_notify_handcuff', "Du bist zu weit entfernt")
        return
    end

    if Player(player).state.moritz_PlayerIsCuffed then
        TriggerClientEvent('moritz_notify_handcuff', "Du kannst niemanden fesseln, während du selbst gefesselt bist")
        return
    end

    if Player(target).state.moritz_PlayerIsCuffed then
        TriggerClientEvent('moritz_notify_handcuff', "Diese Person ist bereits gefesselt")
        return
    end

    Player(target).state.moritz_PlayerIsCuffed = true

    if playerheading then
        TriggerClientEvent("moritz_handcuffs:cuffMe", target, playerheading, coords, playerlocation)
        TriggerClientEvent("moritz_handcuffs:cuffHim", player, true)
    else
        TriggerClientEvent("moritz_handcuffs:cuffMe", target)
        TriggerClientEvent("moritz_handcuffs:cuffHim", player, false)
    end

    TriggerClientEvent('moritz_notify_handcuff',"Du hast die ID gefesselt: ["..target.."]")
    local xTarget = ESX.GetPlayerFromId(target)
    xTarget.showNotification("Du wurdest gefesselt von ID: ["..player.."]")

    local targetLicense = string.gsub(GetPlayerIdentifier(player,1),"license:","")
end)

RegisterNetEvent("moritz_handcuffs:uncuffPlayer", function(target, playerheading, coords, playerlocation)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if Player(player).state.moritz_PlayerIsCuffed then
        TriggerClientEvent('moritz_notify_handcuff',"Du kannst keine Kabelbinder lösen, während du selbst gefesselt bist.")
        return
    end

    if not Player(target).state.moritz_PlayerIsCuffed then
        TriggerClientEvent('moritz_notify_handcuff',"Diese Person ist nicht gefesselt")
        return
    end

    Player(target).state.moritz_PlayerIsCuffed = false

    TriggerClientEvent("moritz_handcuffs:uncuffMe", target, playerheading, coords, playerlocation)
    TriggerClientEvent("moritz_handcuffs:uncuffHim", player)

    TriggerClientEvent('moritz_notify_handcuff',"Du hast die Kabelbinder entfernt von ID: ["..target.."]")
    local xTarget = ESX.GetPlayerFromId(target)
    xTarget.showNotification("Du wurdest festgenmmen von ID: ["..player.."]")

    local targetLicense = string.gsub(GetPlayerIdentifier(player,1),"license:","")
end)

RegisterNetEvent("moritz_handcuffs:searchInventory", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local targetLicense = string.gsub(GetPlayerIdentifier(player,1),"license:","")
    if Player(player).state.moritz_PlayerIsCuffed then
        TriggerClientEvent('moritz_notify_handcuff',"Du kannst niemanden durchsuchen, während du gefesselt bist")
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local distance = #(targetCoords-localCoords)

    if distance > 6.0 then
        TriggerClientEvent('moritz_notify_handcuff',"Diese Person ist zu weit entfernt!")
        return
    end

    --if Player(target).state.moritz_HaveOpenedInventory then
    --    TriggerClientEvent('moritz_notify_handcuff',("Juz ktoś przeszukuje tą osobę")
    --    return
    --end

    Player(target).state.moritz_HaveOpenedInventory = true
    Player(source).state.moritz_IsPlayerSearchingInventory = target
    TriggerClientEvent("moritz_handcuffs:getInventory", player, target)

    TriggerClientEvent('moritz_notify_handcuff',"Du durchsuchst ID: ["..target.."]")
    local xTarget = ESX.GetPlayerFromId(target)
    xTarget.showNotification("Du wurdest durchsucht von ID: ["..player.."]")
end)

RegisterNetEvent("moritz_handcuffs:uncuffed", function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if Player(player).state.moritz_PlayerIsCuffed then
        Player(player).state.moritz_PlayerIsCuffed = false
        return
    end
end)

RegisterNetEvent("moritz_handcuffs:dragPlayer", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if not target then
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    if not targetCoords then
        return
    end
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local dist = #(targetCoords-localCoords)

    if dist > 10.0 then
        TriggerClientEvent('moritz_notify_handcuff',"Du bist zu weit entfernt!")
    
        return
    end
    
    if Player(target).state.moritz_PlayerIsDragged then
        TriggerClientEvent('moritz_notify_handcuff',"Der Spieler wird bereits transportiert!")
        return
    end

    Player(target).state.moritz_PlayerIsDragged = true
    Player(player).state.moritz_PlayerDraggingSomeone = true

    TriggerClientEvent("moritz_handcuffs:dragMe", target, player)
end)

RegisterNetEvent("moritz_handcuffs:unDragPlayer", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if not target then
        if Player(player).state.moritz_PlayerDraggingSomeone then
            Player(player).state.moritz_PlayerDraggingSomeone = false
        end
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    if not targetCoords then
        return
    end
    local localCoords = GetEntityCoords(GetPlayerPed(player))
    local dist = #(targetCoords-localCoords)

    if dist > 10.0 then
        TriggerClientEvent('moritz_notify_handcuff',"Der Spieler ist zu weit entfernt")
        return
    end
    
    if not Player(target).state.moritz_PlayerIsDragged then
        TriggerClientEvent('moritz_notify_handcuff',"Der Spieler wird nicht transportiert")
        return
    end

    Player(target).state.moritz_PlayerIsDragged = false
    Player(player).state.moritz_PlayerDraggingSomeone = false

    TriggerClientEvent("moritz_handcuffs:unDrag", target)
end)

RegisterNetEvent("moritz_handcuffs:closeInventory", function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if not Player(player).state.moritz_IsPlayerSearchingInventory then
        return
    end

    if Player(player).state.moritz_IsPlayerSearchingInventory ~= 0 then
        local target = Player(player).state.moritz_IsPlayerSearchingInventory
        Player(target).state.moritz_HaveOpenedInventory = false
        Player(player).state.moritz_IsPlayerSearchingInventory = 0
    end
end)

RegisterNetEvent("moritz_handcuffs:setPedIntoVehicle", function(target,vehicle,seat)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local coords = GetEntityCoords(GetPlayerPed(player))

    local targetPed = GetPlayerPed(target)
    local targetCoords = GetEntityCoords(targetPed)

    local dist = #(coords - targetCoords)

    if dist > 10.0 then
        TriggerClientEvent('moritz_notify_handcuff',"Der Spieler ist zu weit entfernt")
    
        return
    end

    TriggerClientEvent("moritz_handcuffs:setMeInVehicle",target,vehicle,seat)
end)

RegisterNetEvent("moritz_handcuffs:lockpickDelete", function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local item = xPlayer.getInventoryItem(Config.req_items['lockpick'])
    if item.count > 0 then
        TriggerClientEvent('moritz_notify_handcuff',"Die Schere ist Stumpf geworden")
        xPlayer.removeInventoryItem(Config.req_items['lockpick'],1)
    end
end)

RegisterNetEvent("moritz_handcuffs:getPedFromVehicle", function(target)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local coords = GetEntityCoords(GetPlayerPed(player))

    local targetPed = GetPlayerPed(target)
    local targetCoords = GetEntityCoords(targetPed)

    local dist = #(coords - targetCoords)

    if dist > 10.0 then
        TriggerClientEvent('moritz_notify_handcuff',"Der Spieler ist zu weit entfernt")
        return
    end

    TriggerClientEvent("moritz_handcuffs:leaveVehicle",target)
end)
