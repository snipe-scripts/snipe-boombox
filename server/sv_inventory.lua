-----------------For support, scripts, and more----------------
--------------- https://discord.gg/AeCVP2F8h7  -------------
---------------------------------------------------------------

if Config.Framework == "qb" then
    QBCore = exports["qb-core"]:GetCoreObject()
elseif Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
end

function GetPlayerFrameworkIdentifier(source)
    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.citizenid
        else
            return false
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.identifier
        else
            return false
        end
    end
end

function AddItem(source, item, count)
    if Config.Framework == "qb" then
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.Functions.AddItem(item, count) then
            return true
        else
            return false
        end
    elseif Config.Framework == "esx" then
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.canCarryItem(item, count) then
            xPlayer.addInventoryItem(item, count)
            return true
        else
            return false
        end
    end
end

function RemoveItem(source, item, count)
    if Config.Framework == "qb" then
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.Functions.RemoveItem(item, count) then
            return true
        else
            return false
        end
    elseif Config.Framework == "esx" then
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.getInventoryItem(item).count >= count then
            xPlayer.removeInventoryItem(item, count)
            return true
        else
            return false
        end
    end
end

CreateThread(function()
    if Config.Framework == "qb" then
        for k, v in pairs(ItemTable) do
            QBCore.Functions.CreateUseableItem(k, function(source, item)
                local src = source
                local prop = v.prop
                TriggerClientEvent('snipe-boombox:client:PlaceBoombox', src, 1, prop, k)
            end)
        end
        
    elseif Config.Framework == "esx" then
        for k, v in pairs(ItemTable) do
            ESX.RegisterUsableItem(k, function(source)
                local src = source
                local prop = v.prop
                TriggerClientEvent('snipe-boombox:client:PlaceBoombox', src, 1, prop, k)
            end)
        end
    end
end)
