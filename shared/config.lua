Config = {}

-- Framework is auto-detected by pl_lib. Override here if needed: "esx", "qb", "qbox"
Config.Framework = "autodetect"

-- Interaction mode.
-- "target"  — uses pl_lib to auto-detect ox_target or qb-target
-- "textui"  — proximity text-UI with E key (works without a targeting resource)
Config.Interaction = "target"

Config.WaterMark = true

Config.Debug = {
    Prints = false
}

function Config.DebugPrint(message)
    if Config.Debug.Prints then
        print('[pl_blackmarket] ' .. message)
    end
end

-- Account used for purchases.
-- ESX options  : "bank", "cash", "black_money"
-- QBCore options: "bank", "cash", "black_money"
-- Qbox options : "bank", "cash", "black_money"
-- Note: "black_money" is handled as an inventory item on QBCore/Qbox.
Config.Account = "black_money"

Config.BlackListedJob = { 'police' }

Config.Categories = {
    pistols = {
        label = "Pistol",
        items = {
            { name = "weapon_pistol",        label = "9mm Pistol",       price = 3000, stock = 50 },
            { name = "weapon_appistol",       label = "AP Pistol",        price = 4000, stock = 50 },
            { name = "weapon_combatpistol",   label = "Combat Pistol",    price = 3500, stock = 50 },
            { name = "weapon_heavypistol",    label = "Heavy Pistol",     price = 4500, stock = 50 },
            { name = "weapon_machinepistol",  label = "Machine Pistol",   price = 5000, stock = 50 },
            { name = "weapon_ceramicpistol",  label = "Ceramic Pistol",   price = 2000, stock = 50 },
            { name = "weapon_pistolxm3",      label = "WM 29 Pistol",     price = 2200, stock = 50 },
        }
    },
    rifles = {
        label = "Rifles",
        items = {
            { name = "weapon_advancedrifle",       label = "Advanced Rifle",      price = 15000, stock = 50 },
            { name = "weapon_assaultrifle",        label = "Assault Rifle",       price = 14000, stock = 50 },
            { name = "weapon_assaultrifle_mk2",    label = "Assault Rifle MK2",   price = 17000, stock = 50 },
            { name = "weapon_bullpuprifle",        label = "Bullpup Rifle",       price = 13000, stock = 50 },
            { name = "weapon_bullpuprifle_mk2",    label = "Bullpup Rifle MK2",   price = 15000, stock = 50 },
            { name = "weapon_carbinerifle",        label = "Carbine Rifle",       price = 16000, stock = 50 },
        }
    },
    tools = {
        label = "Illegal Tools",
        items = {
            { name = "lockpick", label = "Lockpick Set", price = 1200, stock = 50 },
        }
    }
}

-- BlackMarket ped locations are defined server-side only (server/location.lua)
