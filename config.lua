Config = {}

-- Framework detection
Config.Framework = "esx" -- "esx" or "qb"

-- Product data (sent to UI)
Config.Categories = {
    weapons = {
        label = "Weapons",
        items = {
            { name = "weapon_pistol", label = "9mm Pistol", price = 2500, stock = 5 },
            { name = "weapon_knife", label = "Combat Knife", price = 1000, stock = 10 },
        }
    },
    drugs = {
        label = "Drugs",
        items = {
            { name = "weed_pouch", label = "Weed Pack", price = 1500, stock = 20 },
            { name = "coke_pouch", label = "Cocaine Pack", price = 2000, stock = 15 },
        }
    },
    tools = {
        label = "Illegal Tools",
        items = {
            { name = "lockpick", label = "Lockpick Set", price = 800, stock = 25 },
            { name = "hackerdevice", label = "Hacking Device", price = 5000, stock = 3 },
        }
    }
}
