Config = {}

Config.Framework = "esx" -- "esx" or "qb"

Config.Interaction = "ox-target" -- "ox-target","qb-target","textui"

Config.WaterMark = true -- Set to false to disable watermark

Config.Debug = false -- Set to true to enable debug messages

--ESX options: "bank", "cash", "black_money" 
--QBCore options: "bank", "cash"
--QBox options: "bank", "cash"

Config.Account = "cash" 

Config.Categories = {
    pistols = {
    label = "Pistol",
    items = {
        { name = "weapon_pistol", label = "9mm Pistol", price = 3000, stock = 50 },
        { name = "weapon_appistol", label = "AP Pistol", price = 4000, stock = 50 },
        { name = "weapon_combatpistol", label = "Combat Pistol", price = 3500, stock = 50 },
        { name = "weapon_heavypistol", label = "Heavy Pistol", price = 4500, stock = 50 },
        { name = "weapon_machinepistol", label = "Machine Pistol", price = 5000, stock = 50 },
        { name = "weapon_ceramicpistol", label = "Ceramic Pistol", price = 2000, stock = 50 },
        { name = "weapon_pistolxm3", label = "WM 29 Pistol", price = 2200, stock = 50 },
        }
    },
    rifles = {
        label = "Rifles",
        items = {
            { name = "weapon_advancedrifle", label = "Advanced Rifle", price = 15000, stock = 50 },
            { name = "weapon_assaultrifle", label = "Assault Rifle", price = 14000, stock = 50 },
            { name = "weapon_assaultrifle_mk2", label = "Assault Rifle MK2", price = 17000, stock = 50 },
            { name = "weapon_bullpuprifle", label = "Bullpup Rifle", price = 13000, stock = 50 },
            { name = "weapon_bullpuprifle_mk2", label = "Bullpup Rifle MK2", price = 15000, stock = 50 },
            { name = "weapon_carbinerifle", label = "Carbine Rifle", price = 16000, stock = 50 },
        }
    },
    tools = {
        label = "Illegal Tools",
        items = {
            { name = "lockpick", label = "Lockpick Set", price = 1200, stock = 50 },
        }
    }

}

Config.BlackMarket = {
    [1] = {
        ped = 'a_m_m_og_boss_01',
        coords = vector3(-939.8207, -1075.2236, 2.1503),
		heading = 213.8993
    },
    -- Add More
}