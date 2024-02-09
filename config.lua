
-----------------For support, scripts, and more----------------
--------------- https://discord.gg/AeCVP2F8h7  -------------
---------------------------------------------------------------

Config = {}

Config.Framework = 'qb' -- esx
Config.PlayerLoadedEvent = 'QBCore:Client:OnPlayerLoaded' -- esx:playerLoaded

Config.Identifiers = { -- identifiers that will be able to pickup/pause/stop music even if they are not of boombox
    ["license:6d3b6254a50416697dcaa91878e2eb03d9112302"] = true,
    ["fivem:1234"] = true,
    ["steam:1234"] = true,
    ["char1:1234"] = true, -- for esx player identifiers
    ["citizenid"] = true, -- for qbcore citizenid
}


-- You can add as many types of boomboxes you want with different props and different distances
-- if you add an item here, make sure to add the item in your inventory as well.
ItemTable = {
    ["boombox"] = { -- item name
        prop = "prop_boombox_01", -- prop name
        distance = 10.0, -- distance to which the sound will be heard
    },
}