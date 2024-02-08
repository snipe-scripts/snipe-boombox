
-----------------For support, scripts, and more----------------
--------------- https://discord.gg/AeCVP2F8h7  -------------
---------------------------------------------------------------

local sounds = {}

local BoomboxTable = {}

Citizen.CreateThread(function()
    Citizen.Wait(100)
    local LoadJson = json.decode(LoadResourceFile(GetCurrentResourceName(), 'boombox.json'))
    for k,v in ipairs(LoadJson) do
        v.coords = vector3(v.coords['x'], v.coords['y'], v.coords['z'])
    end
    BoomboxTable = LoadJson
end)

lib.callback.register('snipe-boombox:server:getTables', function(source)
    local src = source
    return BoomboxTable
end)

lib.callback.register('snipe-boombox:server:checkCitizenId', function(source, citizenid)
    local identifier = GetPlayerFrameworkIdentifier(source)
    if identifier then
        if identifier == citizenid then
            return true
        else
            return false
        end
    else
        return false
    end
end)

local random = math.random
local function getuuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

RegisterServerEvent('snipe-boombox:server:addNewBoombox', function(loc, model, type, quality, containerName, itemName, heading)
    local source = source
    if RemoveItem(source, itemName, 1) then
        local tableInfo = {}
        tableInfo.coords = loc
        tableInfo.model = model
        tableInfo.heading = heading
        tableInfo.uuid = getuuid()
        tableInfo.citizenid = GetPlayerFrameworkIdentifier(source)
        tableInfo.item = itemName
        tableInfo.distance = ItemTable[itemName].distance
        table.insert(BoomboxTable, tableInfo)
        StoreBoomboxTable()
        TriggerClientEvent('snipe-boombox:client:addNewBoombox', -1, tableInfo)
    end
end)

RegisterServerEvent('snipe-boombox:server:pickup', function(id, coords, item)
    local source = source
    if AddItem(source, item, 1) then
        if BoomboxTable[id] then
            if BoomboxTable[id].coords == coords then
                table.remove(BoomboxTable, id)
                StoreBoomboxTable()
                TriggerClientEvent('snipe-boombox:client:deleteContainer', -1, id, action)
            else
                for k,v in ipairs(BoomboxTable) do
                    if v.coords == coords then
                        table.remove(BoomboxTable,k)
                        StoreBoomboxTable()
                        TriggerClientEvent('snipe-boombox:client:deleteContainer', -1, k, action)
                        return
                    end
                end
            end
        end
    end
end)



function StoreBoomboxTable()
    SaveResourceFile(GetCurrentResourceName(), "boombox.json", json.encode(BoomboxTable), -1)
end

function ShowNotification(source, msg, type)
    TriggerClientEvent("ox_lib:notify", source, {description=msg, type=type})
end

RegisterServerEvent("snipe-boombox:server:playSounds", function(objectData, url)
    exports.xsound:Destroy(-1, objectData.uuid)
    exports.xsound:PlayUrlPos(
        -1,
        objectData.uuid, -- uniqueId
        url, -- sound URL/file name
        0.3, -- volume
        vector3(objectData.coords.x, objectData.coords.y, objectData.coords.z), -- position
        false -- looped
    )
    exports.xsound:Distance(-1, objectData.uuid, objectData.distance)
    sounds[objectData.uuid] = url
end)


RegisterServerEvent("snipe-boombox:server:musicAction", function(uuid, action)
    if action == "pause" then
        exports.xsound:Pause(-1, uuid)
    elseif action == "resume" then
        exports.xsound:Resume(-1, uuid)
    elseif action == "stop" then
        exports.xsound:Destroy(-1, uuid)
        sounds[uuid] = nil
    end
end)

RegisterServerEvent("snipe-boombox:server:modifyVolume", function(uuid, volume)
    exports.xsound:setVolume(-1, uuid, volume)
end)

AddEventHandler("onResourceStop", function(name)
    if name == GetCurrentResourceName() then
        for k,v in pairs(sounds) do
            exports.xsound:Destroy(-1, k)
        end
    end
end)
