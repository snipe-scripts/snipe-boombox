-----------------For support, scripts, and more----------------
--------------- https://discord.gg/AeCVP2F8h7  -------------
---------------------------------------------------------------

isSelecting = nil
isPlacing = false
BoomboxTable = {}
local obj = nil
local heading = 0.0
local isSpawned = true
local currentCoords = nil
isAdmin = false

function ShowNotification(text, type)
    lib.notify({description = text, type = type})
end

RegisterNetEvent(Config.PlayerLoadedEvent, function()
    Wait(1000)
    tabledata = lib.callback.await('snipe-boombox:server:getTables', false)
    isAdmin = lib.callback.await('snipe-boombox:server:isAdmin', false)
    BoomboxTable = tabledata
    isSpawned = true
end)

AddEventHandler('onResourceStop', function(resource)
	if ("snipe-boombox" ~= resource) then return end
	if BoomboxTable then
		for k, v in pairs(BoomboxTable) do
			DeleteEntity(v.obj)
            v.obj = nil
		end
	end
end)

AddEventHandler("onResourceStart", function(resource)
    if ("snipe-boombox" ~= resource) then return end
    Wait(1000)
    tabledata = lib.callback.await('snipe-boombox:server:getTables', false)
    BoomboxTable = tabledata
    isSpawned = true
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(7)
		if isSpawned and BoomboxTable then
			inRange = false
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			for k,v in ipairs(BoomboxTable) do
				local dist = #(pos - v.coords)
				if dist <= 100.0 and v.obj == nil then
					if v.obj == nil then
                        local obj = CreateObject(GetHashKey(v.model), v.coords, false)
                        if v.heading ~= nil then
                            SetEntityHeading(obj, v.heading)
                        end
                        FreezeEntityPosition(obj, true)
                        v.obj = obj
					end
				elseif dist > 100.0 and v.obj ~= nil then
					if v.obj then
						DeleteEntity(v.obj)
						v.obj = nil
					end
				end
			end
		end
		if not inRange then
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent("snipe-boombox:client:PlaceBoombox", function(type,object, itemName)
    if obj == nil then
        local playerPed = PlayerPedId()
        isSelecting = object
        obj = CreateObject(GetHashKey(object), GetEntityCoords(playerPed), 0, 0, 0)
        SetEntityAlpha(obj, 100)
        ShowNotification("Press E to place, Backspace to Cancel", "success")
        CreateThread(function ()
            while isSelecting ~= nil do
                Wait(1)
                DisableControlAction(0, 22, true)
                if not isPlacing then
                    placing()
                end
                if currentCoords then
                    local z = currentCoords.z + 0.3
                    SetEntityCoords(obj, currentCoords.x, currentCoords.y, z)
                    SetEntityHeading(obj, heading)
                end
                if IsDisabledControlJustPressed(0, 174) then
                    heading = heading + 5
                    if heading > 360 then heading = 0.0 end
                end
        
                if IsDisabledControlJustPressed(0, 175) then
                    heading = heading - 5
                    if heading < 0 then heading = 360.0 end
                end
                if IsControlJustPressed(0, 38) then
                    if #(GetEntityCoords(PlayerPedId()) - currentCoords) < 5.0 then
                        PutBoombox(object, currentCoords, heading, type, itemName)
                    else
                        ShowNotification("Too far", "error")
                    end
                end
                if IsControlJustPressed(0, 177) then
                    stopPlacing()
                end
            end
        end)
    else
        ShowNotification("Cancelled", "error")
        DeleteObject(obj)
        obj = nil
        stopPlacing()
        return
    end
end)

function PutBoombox(model, coords, heading, type, itemName)
    RequestModel(GetHashKey(model))
    CreatedObjects = CreateObject(GetHashKey(model), coords, true, false, false)
    SetEntityAlpha(CreatedObjects, 51)
    SetEntityHeading(CreatedObjects, heading)
    FreezeEntityPosition(CreatedObjects, true)
    canPlace = true
    if obj then
        DeleteObject(obj)
    end
    obj = nil
    isSelecting = nil
    currentCoords = nil
    isPlacing = false
    if canPlace then
        DeleteObject(CreatedObjects)
        TriggerServerEvent("snipe-boombox:server:addNewBoombox", coords, model, itemName, heading)
    end
end

RegisterNetEvent('snipe-boombox:client:addNewBoombox', function(data)
	local boombox = data
	if #(GetEntityCoords(PlayerPedId()) - data.coords)<= 150.0 then
		local obj = CreateObject(GetHashKey(data.model), data.coords.x, data.coords.y, data.coords.z, false)
        if data.heading ~= nil then
            SetEntityHeading(obj, data.heading)
        end
        FreezeEntityPosition(obj, true)
        boombox.obj = obj
	end
    
    BoomboxTable[#BoomboxTable + 1] = boombox
end)

function camPosition (ignore)
    local coord = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(0)
    local rx = math.pi / 180 * rot.x
    local rz = math.pi / 180 * rot.z
    local cosRx = math.abs(math.cos(rx))
    local direction = {
        x = -math.sin(rz) * cosRx,
        y = math.cos(rz) * cosRx,
        z = math.sin(rx)
    }

    local coords = {
        coord.x + direction.x,
        coord.y + direction.y,
        coord.z + direction.z,
    }
    local sphereCast = StartShapeTestSweptSphere(
        coord.x + direction.x,
        coord.y + direction.y,
        coord.z + direction.z,
        coord.x + direction.x * 7,
        coord.y + direction.y * 7,
        coord.z + direction.z * 7,
        0.2,
        339,
        ignore,
        4
    );
    return GetShapeTestResult(sphereCast);
end

function placing()
    local _, hit, endCoords, _, _ = camPosition(obj)
    if hit then
        currentCoords = endCoords
    end
end

function stopPlacing()
    if obj then
        DeleteObject(obj)
    end
    heading = 0.0
    isSelecting = nil
    currentCoords = nil
    isPlacing = false

    DeleteObject(obj)
    obj = nil
end

RegisterNetEvent('snipe-boombox:client:deleteBoombox', function(boomboxId, action)
	if BoomboxTable[boomboxId] then
		DeleteEntity(BoomboxTable[boomboxId].obj)
        table.remove(BoomboxTable, boomboxId)
	end
end)

