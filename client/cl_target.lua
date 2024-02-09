-----------------For support, scripts, and more----------------
--------------- https://discord.gg/AeCVP2F8h7  -------------
---------------------------------------------------------------

local props = {}
for k, v in pairs(ItemTable) do
    table.insert(props, v.prop)
end

CreateThread(function()
        exports["qb-target"]:AddTargetModel(props, {
            options = {
                {
                    icon = "fas fa-music", 
                    label = "Music Controls", 
                    action = function(data)
                        OpenControls(data)
                    end
                },
                {
                    icon = "fas fa-hand-paper", 
                    label = "Pick up", 
                    action = function(data)
                        Pickup(data)
                    end
                },
            },
            distance = 3.0
        })
end)


function OpenControls(objectData)
    if BoomboxTable then
		for k, v in ipairs(BoomboxTable) do
			if v.obj == objectData then
                
                local data = lib.callback.await('snipe-boombox:server:checkCitizenId', false, v.citizenid)
                if data or isAdmin then
                    local playing = false
                    local soundExists = false
                    local paused = false
                    if exports.xsound:soundExists(v.uuid) then
                        soundExists = true
                    end
                    if soundExists then
                        playing = exports.xsound:isPlaying(v.uuid)
                        paused = exports.xsound:isPaused(v.uuid)
                    end

                    lib.registerContext({
                        id = 'music_player',
                        title = "Music Player",
                        options = {
                            {
                                title = "Play Music",
                                description = "Play the music",
                                onSelect = function(args)
                                    PlayMusic(v)
                                end,
                            },
                            {
                                title = "Pause Music",
                                description = "Stop the current playing music",
                                disabled = not soundExists or not playing,
                                onSelect = function(args)
                                    MusicPlayerAction(v.uuid, "pause")
                                end,
                            },
                            {
                                title = "Resume Music",
                                description = "Stop the current playing music",
                                disabled = not soundExists or not paused,
                                onSelect = function(args)
                                    MusicPlayerAction(v.uuid, "resume")
                                end,
                            },
                            {
                                title = "Stop Music",
                                description = "Stop the current playing music",
                                disabled = not soundExists,
                                onSelect = function(args)
                                    MusicPlayerAction(v.uuid, "stop")
                                end,
                            },
                            {
                                title = "Volume",
                                description = "Change the volume",
                                disabled = not soundExists,
                                onSelect = function(args)
                                    Volume(v)
                                end,
                            },
                        }
                    })
                    lib.showContext('music_player')
                else
                    ShowNotification("Not your boombox", "error")
                end
            end
        end
    end
end

function PlayMusic(objectData)
    local input = lib.inputDialog('Dialog title', {
        {type = 'input', label = 'Song URL', description = 'Youtube Link Only', required = true},
    })
    if not input then return end
	if not input[1] then return end
    TriggerServerEvent("snipe-boombox:server:playSounds", objectData, input[1])
end

function Volume(v)
    local volume = exports.xsound:getVolume(v.uuid)
    currentValue = 0
    if not volume then 
        ShowNotification("Nothing Playing", "error")
        return
    end
    if volume then
        currentValue = volume * 100
    end
    local input = lib.inputDialog('Dialog title', {
        {type = 'slider', label = 'Volume', default =currentValue,  required = true},
    })

    if not input then return end
    if not input[1] then return end
    TriggerServerEvent("snipe-boombox:server:modifyVolume", v.uuid, (input[1]/100))
end

function MusicPlayerAction(uuid, action)
    TriggerServerEvent("snipe-boombox:server:musicAction", uuid, action)

end

-- RegisterNetEvent("snipe-boombox:client:pickup", function(data)
function Pickup(data)
    local index = 0
	if BoomboxTable then
		for k, v in ipairs(BoomboxTable) do
			if v.obj == data  then
                local data = lib.callback.await('snipe-boombox:server:checkCitizenId',false, v.citizenid)
                if data or isAdmin then
                    index = k
                    TriggerServerEvent("snipe-boombox:server:musicAction", v.uuid, "stop")
                    TriggerServerEvent("snipe-boombox:server:pickup", index, v.coords, v.item)
                else
                    ShowNotification("Not your boombox", "error")
                end
			end
		end
	end
end