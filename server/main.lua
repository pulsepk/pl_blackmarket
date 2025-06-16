
local resourceName = 'pl_blackmarket'
lib.versionCheck('pulsepk/pl_blackmarket')

local QBCore, ESX = nil, nil

if Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
end

local currentStock = {}
local products = {}


if GetResourceState('ox_inventory') == 'started' then
    ImagesPath = 'ox_inventory/web/images/'
elseif GetResourceState('qs-inventory') == 'started' then
    ImagesPath = 'qs-inventory/html/images/'
elseif GetResourceState('qb-inventory') == 'started' then
    ImagesPath = 'qb-inventory/html/images/'
elseif GetResourceState('ps-inventory') == 'started' then
    ImagesPath = 'ps-inventory/html/images/'
elseif GetResourceState('codem-inventory') == 'started' then
    ImagesPath = 'codem-inventory/html/images/'
elseif GetResourceState('tgiann-inventory') == 'started' then
    ImagesPath = 'tgiann-inventory/images/'
elseif GetResourceState('ak47_inventory') == 'started' then
    ImagesPath = 'ak47_inventory/web/build/images/'
elseif GetResourceState('origen_inventory') == 'started' then
    ImagesPath = 'origen_inventory/html/images/'
else
    print('[WARNING] Inventory not detected. Using default image path.')
    ImagesPath = 'ox_inventory/web/images/'
end

function debug(msg)
    if Config.Debug then
        print(msg)
    end
end

lib.callback.register('pl_blackmarket:checkPlayerFunds', function(source, total)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getAccount(Config.Account).money >= total
    elseif Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.Functions.GetMoney(Config.Account) >= total
    end
    return false
end)

RegisterNetEvent('pl_blackmarket:server:purchaseItems', function(cart, total)
    local src = source

    local player, money, removeMoney, addItem

    if Config.Framework == "esx" then
        player = ESX.GetPlayerFromId(src)
        money = player.getAccount(Config.Account).money
        removeMoney = function(amount)
            player.removeAccountMoney(Config.Account, amount)
        end
        addItem = function(name, quantity)
            if GetResourceState(resourceName) == 'started' then
                exports.ox_inventory:AddItem(src, name, quantity)
            else
                player.addInventoryItem(name, quantity)
            end
        end

    elseif Config.Framework == "qb" then
        player = QBCore.Functions.GetPlayer(src)
        money = player.Functions.GetMoney(Config.Account)
        removeMoney = function(amount)
            player.Functions.RemoveMoney(Config.Account, amount)
        end
        addItem = function(name, quantity)
            if GetResourceState(resourceName) == 'started' then
                exports.ox_inventory:AddItem(src, name, quantity)
            else
                player.Functions.AddItem(name, quantity)
            end
        end
    else
        debug("[Blackmarket] Unknown framework configured.")
        return
    end

    if money < total then
        debug(("[Blackmarket] Player %s tried to purchase without enough money."):format(src))
        return
    end

    removeMoney(total)
    debug(("[Blackmarket] Removed $%s from Player %s"):format(total, src))

    for itemName, itemData in pairs(cart) do
        local quantity = tonumber(itemData.quantity)
        if quantity and quantity > 0 then
            if currentStock[itemName] and currentStock[itemName] >= quantity then
                currentStock[itemName] = currentStock[itemName] - quantity
                addItem(itemName, quantity)
                debug(("[Blackmarket] Removed %s from stock of item '%s'"):format(quantity, itemName))
            else
                debug(("[Blackmarket] Not enough stock to remove %s of '%s'"):format(quantity, itemName))
            end
        end
    end
end)


RegisterNetEvent("pl_blackmarket:OpenUI", function()
    for categoryKey, categoryData in pairs(Config.Categories) do
        products[categoryData.label] = {}

        for _, item in pairs(categoryData.items) do
            currentStock[item.name] = currentStock[item.name] or item.stock

            table.insert(products[categoryData.label], {
                name = item.name,
                label = item.label,
                price = "$" .. item.price,
                stock = currentStock[item.name],
                icon = "nui://"..ImagesPath .. string.upper(item.name) .. ".png"
            })
        end
    end
    TriggerClientEvent("pl_blackmarket:client:open", source, products)
end)

local WaterMark = function()
    SetTimeout(1500, function()
        print('^1['..resourceName..'] ^2Thank you for Downloading the Script^0')
        print('^1['..resourceName..'] ^2If you encounter any issues please Join the discord https://discord.gg/c6gXmtEf3H to get support..^0')
        print('^1['..resourceName..'] ^2Enjoy a secret 20% OFF any script of your choice on https://pulsescripts.tebex.io/freescript^0')
        print('^1['..resourceName..'] ^2Using the coupon code: SPECIAL20 (one-time use coupon, choose wisely)^0')
    
    end)
end

if Config.WaterMark then
    WaterMark()
end

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, categoryData in pairs(Config.Categories) do
        for _, item in pairs(categoryData.items) do
            currentStock[item.name] = item.stock
        end
    end
    end
end)

