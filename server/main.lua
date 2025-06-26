
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

local function GetPlayerJob(source)
    local jobName = nil

    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.job then
            jobName = xPlayer.job.name
        end
    elseif Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            jobName = Player.PlayerData.job.name
        end
    elseif Config.Framework == "qbox" then
        local Player = exports.qbx_core:GetPlayer(source)
        if Player then
            jobName = Player.PlayerData.job.name
        end
    end

    return jobName
end

local function IsJobBlacklisted(job)
    for _, blacklisted in ipairs(Config.BlackListedJob) do
        if job == blacklisted then
            return true
        end
    end
    return false
end

lib.callback.register('pl_blackmarket:checkPlayerFunds', function(source, total)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getAccount(Config.Account).money >= total
    elseif Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.Functions.GetMoney(Config.Account) >= total
    elseif Config.Framework == "qbox" then
        if Config.Account == "black_money" then
            return exports.ox_inventory:GetItemCount(source, "black_money") >= total
        else
            return exports.qbx_core:GetMoney(source, Config.Account) >= total
        end
    end
    return false
end)

RegisterNetEvent('pl_blackmarket:server:purchaseItems', function(cart)
    local src = source
    local totalPrice = 0
    local player, money, removeMoney, addItem
    if Config.Framework == "esx" then
        player = ESX.GetPlayerFromId(src)
        money = player.getAccount(Config.Account).money
        removeMoney = function(amount)
            player.removeAccountMoney(Config.Account, amount)
        end
        addItem = function(name, quantity)
            if GetResourceState('ox_inventory') == 'started' then
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
            if GetResourceState('ox_inventory') == 'started' then
                exports.ox_inventory:AddItem(src, name, quantity)
            else
                player.Functions.AddItem(name, quantity)
            end
        end

    elseif Config.Framework == "qbox" then
        player = exports.qbx_core:GetPlayer(src)
        money = exports.qbx_core:GetMoney(src, Config.Account)
        removeMoney = function(amount)
            if Config.Account == "black_money" then
                exports.ox_inventory:RemoveItem(src, "black_money", amount, false)
            else
                exports.qbx_core:RemoveMoney(src, Config.Account, amount, "Black Market Purchase")
            end
        end
        addItem = function(name, quantity)
            if GetResourceState('ox_inventory') == 'started' then
                exports.ox_inventory:AddItem(src, name, quantity)
            end
        end
    else
        print("[Blackmarket] Unknown framework configured.")
        return
    end

    for itemName, itemData in pairs(cart) do
        local quantity = tonumber(itemData.quantity) or 0
        if quantity > 0 then
            local itemConfig = nil
            for _, category in pairs(Config.Categories) do
                for _, item in pairs(category.items) do
                    if item.name == itemName then
                        itemConfig = item
                        break
                    end
                end
                if itemConfig then break end
            end
            if itemConfig then
                if currentStock[itemName] and currentStock[itemName] >= quantity then
                    local itemPrice = itemConfig.price * quantity
                    totalPrice = totalPrice + itemPrice
                else
                    print(("[Blackmarket] Not enough stock for '%s'"):format(itemName))
                    return
                end
            else
                print(("[Blackmarket] Invalid item in cart: '%s'"):format(itemName))
                return
            end
        end
    end
    if money < totalPrice then
        print(("[Blackmarket] Player %s tried to purchase for $%s but only has $%s"):format(src, totalPrice, money))
        return
    end

    removeMoney(totalPrice)
    print(("[Blackmarket] Charged $%s from Player %s"):format(totalPrice, src))

    for itemName, itemData in pairs(cart) do
        local quantity = tonumber(itemData.quantity)
        if quantity and quantity > 0 and currentStock[itemName] then
            currentStock[itemName] = currentStock[itemName] - quantity
            addItem(itemName, quantity)
            print(("[Blackmarket] Gave %sx '%s' to Player %s"):format(quantity, itemName, src))
        end
    end
end)



RegisterNetEvent("pl_blackmarket:OpenUI", function()
    local src = source
    local job = GetPlayerJob(src)

    if IsJobBlacklisted(job) then
        local data = {
            title = 'Black Market',
            description = 'Access denied for blacklisted job',
            type = 'error'
        }
        TriggerClientEvent('ox_lib:notify', source, data)
        return
    end
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

