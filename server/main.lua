
local resourceName = GetCurrentResourceName()
exports.pl_lib:CheckVersion(resourceName, true)

local currentStock = {}
local products     = {}
local ImagesPath   = exports.pl_lib:GetImagesPath()

local function IsJobBlacklisted(job)
    for _, blacklisted in ipairs(Config.BlackListedJob) do
        if job == blacklisted then return true end
    end
    return false
end

-- Maps Config.Account names to pl_lib's bridge key ('money' / 'bank').
-- 'black_money' is handled separately via inventory item, not a money account.
local function AccountKey()
    if Config.Account == 'cash' then return 'money' end
    return Config.Account
end

-- ── Fund check callback (client → server) ────────────────────────────────────

lib.callback.register('pl_blackmarket:checkPlayerFunds', function(source, total)
    if Config.Account == 'black_money' then
        return exports.pl_lib:HasItem(source, 'black_money') >= total
    end
    return exports.pl_lib:GetPlayerAccountMoney(source, AccountKey(), total)
end)

-- ── Purchase handler ──────────────────────────────────────────────────────────

RegisterNetEvent('pl_blackmarket:server:purchaseItems', function(cart)
    local src = source

    -- Security: verify the player is physically near a blackmarket ped server-side.
    if not IsPlayerNearBlackMarket(src) then
        Config.DebugPrint(("Player %s tried to purchase but is not near any blackmarket ped"):format(src))
        return
    end

    local totalPrice = 0

    for itemName, itemData in pairs(cart) do
        local quantity = tonumber(itemData.quantity) or 0
        if quantity > 0 then
            local itemConfig = nil
            for _, category in pairs(Config.Categories) do
                for _, item in pairs(category.items) do
                    if item.name == itemName then itemConfig = item; break end
                end
                if itemConfig then break end
            end

            if not itemConfig then
                Config.DebugPrint(("Invalid item in cart: '%s'"):format(itemName))
                return
            end

            if not (currentStock[itemName] and currentStock[itemName] >= quantity) then
                Config.DebugPrint(("Not enough stock for '%s'"):format(itemName))
                return
            end

            totalPrice = totalPrice + (itemConfig.price * quantity)
        end
    end

    -- Server-side re-verification of funds (never trust the client callback alone).
    local hasEnough
    if Config.Account == 'black_money' then
        hasEnough = exports.pl_lib:HasItem(src, 'black_money') >= totalPrice
    else
        hasEnough = exports.pl_lib:GetPlayerAccountMoney(src, AccountKey(), totalPrice)
    end

    if not hasEnough then
        Config.DebugPrint(("Player %s has insufficient funds for $%s"):format(src, totalPrice))
        return
    end

    -- Deduct payment
    if Config.Account == 'black_money' then
        exports.pl_lib:RemoveItem(src, 'black_money', totalPrice)
    else
        exports.pl_lib:RemovePlayerMoney(src, AccountKey(), totalPrice, 'Black Market Purchase')
    end
    Config.DebugPrint(("Charged $%s from Player %s"):format(totalPrice, src))

    -- Deliver items
    for itemName, itemData in pairs(cart) do
        local quantity = tonumber(itemData.quantity)
        if quantity and quantity > 0 and currentStock[itemName] then
            currentStock[itemName] = currentStock[itemName] - quantity
            exports.pl_lib:AddItem(src, itemName, quantity)
            Config.DebugPrint(("Gave %sx '%s' to Player %s"):format(quantity, itemName, src))
        end
    end
end)

-- ── Open UI handler ───────────────────────────────────────────────────────────

RegisterNetEvent('pl_blackmarket:OpenUI', function()
    local src = source

    if not IsPlayerNearBlackMarket(src) then
        Config.DebugPrint(("Player %s tried to open UI but is not near any blackmarket ped"):format(src))
        return
    end

    local job = exports.pl_lib:GetJob(src)

    if IsJobBlacklisted(job) then
        Config.DebugPrint(("Player %s denied access — blacklisted job: %s"):format(src, tostring(job)))
        TriggerClientEvent('pl_blackmarket:client:notify', src, {
            title       = 'Black Market',
            description = 'Access denied for your job',
            type        = 'error'
        })
        return
    end

    Config.DebugPrint(("Player %s opened the Black Market UI"):format(src))

    for _, categoryData in pairs(Config.Categories) do
        products[categoryData.label] = {}
        for _, item in pairs(categoryData.items) do
            currentStock[item.name] = currentStock[item.name] or item.stock
            table.insert(products[categoryData.label], {
                name  = item.name,
                label = item.label,
                price = "$" .. item.price,
                stock = currentStock[item.name],
                icon  = ImagesPath .. string.upper(item.name) .. ".png"
            })
        end
    end

    TriggerClientEvent("pl_blackmarket:client:open", src, products)
end)

-- ── Startup / watermark ───────────────────────────────────────────────────────

if Config.WaterMark then
    SetTimeout(1500, function()
        print('^1[' .. resourceName .. '] ^2Thank you for downloading the script^0')
        print('^1[' .. resourceName .. '] ^2Support: https://discord.gg/c6gXmtEf3H^0')
        print('^1[' .. resourceName .. '] ^2Use coupon SPECIAL20 for 20%% off at https://pulsescripts.com/^0')
    end)
end

AddEventHandler('onServerResourceStart', function(name)
    if name ~= GetCurrentResourceName() then return end
    for _, categoryData in pairs(Config.Categories) do
        for _, item in pairs(categoryData.items) do
            currentStock[item.name] = item.stock
        end
    end
end)
