Config = {}

Config.Framework = 'qb' -- esx


-- You can add as many types of boomboxes you want with different props and different distances
-- if you add an item here, make sure to add the item in your inventory as well.
ItemTable = {
    ["boombox"] = { -- item name
        prop = "prop_boombox_01", -- prop name
        distance = 10.0, -- distance to which the sound will be heard
    },
}