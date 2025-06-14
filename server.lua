local QBCore, ESX = nil, nil

if Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

RegisterServerEvent('blackmarket:server:purchaseItem', function(data)
    local src = source
    local itemName = data.name
    local category = data.category
    local amount = tonumber(data.amount or 1)

    if not Config.Categories[category] then return end

    local itemInfo
    for _, v in pairs(Config.Categories[category].items) do
        if v.name == itemName then
            itemInfo = v
            break
        end
    end

    if not itemInfo then return end
    if itemInfo.stock < amount then
        TriggerClientEvent('blackmarket:client:notify', src, "Not enough stock!", "error")
        return
    end

    local totalPrice = itemInfo.price * amount

    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player.Functions.RemoveMoney('cash', totalPrice, "blackmarket-purchase") then
            Player.Functions.AddItem(itemName, amount)
            itemInfo.stock -= amount
            TriggerClientEvent('blackmarket:client:notify', src, "Purchased " .. amount .. "x " .. itemInfo.label, "success")
        else
            TriggerClientEvent('blackmarket:client:notify', src, "Not enough money!", "error")
        end

    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.getMoney() >= totalPrice then
            xPlayer.removeMoney(totalPrice)
            xPlayer.addInventoryItem(itemName, amount)
            itemInfo.stock -= amount
            TriggerClientEvent('blackmarket:client:notify', src, "Purchased " .. amount .. "x " .. itemInfo.label, "success")
        else
            TriggerClientEvent('blackmarket:client:notify', src, "Not enough money!", "error")
        end
    end
end)
