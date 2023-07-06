-----------------For support, scripts, and more----------------
--------------- https://discord.gg/fz655NHeDq  -------------
---------------------------------------------------------------
local spawnedSounds = {}

RegisterCommand('carplay', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SendNUIMessage({
            event = "openCarPlay",
            veh = VehToNet(vehicle),
            vehIdStr = tostring(VehToNet(vehicle)),
            queue = Entity(vehicle).state.queue
        }) 
        SetNuiFocus(true, true)
    else
        notify("Must be in a vehicle", "error", "Error", 5000)
    end
end)

RegisterNUICallback('closeCarPlay', function(cd)
    SetNuiFocus(false, false)
end)

function vehicleEntered(veh)
    if Entity(veh).state then
        local currQueue = Entity(veh).state.queue
        if currQueue ~= nil then
            local data = currQueue[Entity(veh).state.queuePos]
            local currTime = Entity(veh).state.currTime
            if data ~= nil then

                if exports.xsound:soundExists("nass_carplay_"..data.vehStr) then
                    exports.xsound:Destroy("nass_carplay_"..data.vehStr)
                end
                local volume = 1.0
                local SavedVol = Entity(NetToVeh(data.veh)).state.volume
                if SavedVol ~= nil then
                    volume = SavedVol
                end
                exports.xsound:PlayUrl("nass_carplay_"..data.vehStr, data.link, volume, false, {
                    onPlayStart = function(event)
                        table.insert(spawnedSounds, NetToVeh(data.veh))
                        SendNUIMessage({
                            event = "playbackStarted",
                            link = data.link,
                            vol = exports.xsound:getVolume("nass_carplay_"..data.vehStr)
                        })

                        exports.xsound:setTimeStamp("nass_carplay_"..data.vehStr, math.floor(currTime))
                        if Entity(veh).state.isPaused then
                            exports.xsound:Pause("nass_carplay_"..data.vehStr)
                            SendNUIMessage({
                                event = "setPicPaused",
                            })
                        end
                        local totalDurr = exports.xsound:getMaxDuration("nass_carplay_"..data.vehStr)
                        CreateThread(function()
                            while true do
                                Wait(999)

                                if totalDurr == 0 then
                                    totalDurr = exports.xsound:getMaxDuration("nass_carplay_"..data.vehStr)
                                end

                                if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then
                                    break
                                end

                                local currTime = exports.xsound:getTimeStamp("nass_carplay_"..data.vehStr)
                                Entity(NetToVeh(data.veh)).state:set('currTime', currTime, true)

                                if currTime+1 == totalDurr then
                                    TriggerEvent("nass_carplay:playsound", {event = "nextSong", veh =data.veh, vehStr = data.vehStr})
                                    shouldBreak = true
                                end

                                SendNUIMessage({
                                    event = "updateTime",
                                    time = {currentTime = currTime, totalDuration = totalDurr}
                                })
                
                                if GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
                                    SendNUIMessage({event = "resetPlayback"})
                                    exports.xsound:Destroy("nass_carplay_"..data.vehStr)
                                    shouldBreak = true
                                end
                
                                if shouldBreak then      
                                    SendNUIMessage({
                                        event = "updateTime",
                                        time = {currentTime = 0, totalDuration = 0}
                                    })  
                                    shouldBreak = false
                                    break
                                end
                                Wait(1)
                            end
                        end)  
                    end
                    }) 

                print("data found")
            
            end
        end
    end
end

RegisterNetEvent('nass_carplay:playsound')
AddEventHandler("nass_carplay:playsound", function(data)
    if data.event == "url" then
        if data.shouldForce then
            shouldBreak = true
            Wait(10)
            shouldBreak = false
        end

        if not data.shouldForce and exports.xsound:soundExists("nass_carplay_"..data.vehStr) then
            local currQueue = Entity(NetToVeh(data.veh)).state.queue
            if currQueue == nil then 
                currQueue = {}
            end
            data.queuePos = #currQueue+1
            table.insert(currQueue, data)
            Entity(NetToVeh(data.veh)).state:set('queue', currQueue, true)
        else
            
            if data.queuePos then
                Entity(NetToVeh(data.veh)).state:set('queuePos', data.queuePos, true)
            end

            local currQueue = Entity(NetToVeh(data.veh)).state.queue
            if currQueue == nil then
                local queue = {}
                if data.queuePos == nil then
                    data.queuePos = 1
                end
                table.insert(queue, data)
                Entity(NetToVeh(data.veh)).state:set('queue', queue, true)
            end

            if exports.xsound:soundExists("nass_carplay_"..data.vehStr) then
                exports.xsound:Destroy("nass_carplay_"..data.vehStr)
            end
            local volume = 1.0
            local SavedVol = Entity(NetToVeh(data.veh)).state.volume
            if SavedVol ~= nil then
                volume = SavedVol
            end
            exports.xsound:PlayUrl("nass_carplay_"..data.vehStr, data.link, volume, false, {
                onPlayStart = function(event)
                    table.insert(spawnedSounds, NetToVeh(data.veh))
                    SendNUIMessage({
                        event = "playbackStarted",
                        link = data.link,
                        vol = exports.xsound:getVolume("nass_carplay_"..data.vehStr)
                    })

                    local totalDurr = exports.xsound:getMaxDuration("nass_carplay_"..data.vehStr)
                    
                    CreateThread(function()
                        while true do
                            Wait(999)
                            if totalDurr == 0 then
                                totalDurr = exports.xsound:getMaxDuration("nass_carplay_"..data.vehStr)
                            end

                            if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then
                                break
                            end

                            local currTime = exports.xsound:getTimeStamp("nass_carplay_"..data.vehStr)
                            Entity(NetToVeh(data.veh)).state:set('currTime', currTime, true)

                            if currTime+1 == totalDurr then
                                TriggerEvent("nass_carplay:playsound", {event = "nextSong", veh = data.veh, vehStr = data.vehStr})
                                shouldBreak = true
                            end

                            SendNUIMessage({
                                event = "updateTime",
                                time = {currentTime = currTime, totalDuration = totalDurr}
                            })
            
                            if GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
                                SendNUIMessage({event = "resetPlayback"})
                                exports.xsound:Destroy("nass_carplay_"..data.vehStr)
                                shouldBreak = true
                            end
            
                            if shouldBreak then   
                                SendNUIMessage({
                                    event = "updateTime",
                                    time = {currentTime = 0, totalDuration = 0}
                                })      
                                shouldBreak = false
                                break
                            end
                            Wait(1)
                        end
                    end)   
                end,
                onPlayEnd = function(event)
                    shouldBreak = true
                end,
            }) 
        end  
    elseif data.event == "resume" then
        if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then return end

        exports.xsound:Resume("nass_carplay_"..data.vehStr)
        Entity(NetToVeh(data.veh)).state:set('isPaused', false, true)
    elseif data.event == "pause" then
        if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then return end

        exports.xsound:Pause("nass_carplay_"..data.vehStr)
        Entity(NetToVeh(data.veh)).state:set('isPaused', true, true)
    elseif data.event == "resetPlayback" then
        exports.xsound:Destroy("nass_carplay_"..data.vehStr)
    elseif data.event == "setVolume" then
        if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then return end

        local newVol = math.floor(data.vol)/100
        exports.xsound:setVolume("nass_carplay_"..data.vehStr, newVol)
        Entity(NetToVeh(data.veh)).state:set('volume', newVol, true)
    elseif data.event == "breakLoop" then
        shouldBreak = true
	elseif data.event == "selectTime" then
        if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then return end

	    exports.xsound:setTimeStamp("nass_carplay_"..data.vehStr, math.floor(data.newTime))
        Wait(50)
    elseif data.event == "restartSong" then
        if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then return end

        exports.xsound:setTimeStamp("nass_carplay_"..data.vehStr, math.floor(0))
    elseif data.event == "nextSong" then
        if not exports.xsound:soundExists("nass_carplay_"..data.vehStr) then return end
        local currQueue = Entity(NetToVeh(data.veh)).state.queue
        local currQueuePos = Entity(NetToVeh(data.veh)).state.queuePos
        if currQueuePos == nil then 
            if exports.xsound:soundExists("nass_carplay_"..data.vehStr) then
                exports.xsound:Destroy("nass_carplay_"..data.vehStr)
            end
            SendNUIMessage({
                event = "updateTime",
                time = {currentTime = 0, totalDuration = 0}
            })
            SendNUIMessage({event = "resetPlayback"})
            shouldBreak = true
            return 
        end
        local dat = currQueue[currQueuePos+1]
        if dat ~= nil then
            dat.shouldForce = true
            Wait(1)
            if exports.xsound:soundExists("nass_carplay_"..data.vehStr) then
                exports.xsound:Destroy("nass_carplay_"..data.vehStr)
            end
            Wait(1)

            local peds = getPeds(NetToVeh(data.veh))
            TriggerServerEvent("nass_carplay:syncmusic", peds, data.veh, dat)
        else
            SendNUIMessage({
                event = "updateTime",
                time = {currentTime = 0, totalDuration = 0}
            })
            SendNUIMessage({event = "resetPlayback"})
        end
	end
end)

RegisterNUICallback('callback', function(data)
    if data.veh ~= nil then
        if data.event == "url" or data.event == "forceurl" then
            if data.event == "forceurl" then
                data.event = "url"
                data.shouldForce = true
            end
            Entity(NetToVeh(data.veh)).state:set('data', data, true)
        end
        local peds = getPeds(NetToVeh(data.veh))
        TriggerServerEvent("nass_carplay:syncmusic", peds, data.veh, data)
    end
end)

function notify(msg, type, title, time)
    if GetResourceState('nass_notifications') == 'started' then
        exports["nass_notifications"]:ShowNotification(type, title, msg, time)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(0, 1)
    end
end

function getPeds(veh)
    local peds = {}
    for i = -1, (GetVehicleMaxNumberOfPassengers(veh)-1), 1 do
        local ped = GetPedInVehicleSeat(veh, i)
        if ped ~= 0 then
            table.insert(peds, GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)))
        end
    end
    return peds
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
   
    for k,v in pairs(spawnedSounds) do
        Entity(v).state:set('data', nil, true)
        Entity(v).state:set('currTime', nil, true)
        Entity(v).state:set('queue', nil, true)
        Entity(v).state:set('queuePos', 1, true)
        Entity(v).state:set('isPaused', 1, false)
        if exports.xsound:soundExists("nass_carplay_"..v) then
            exports.xsound:Destroy("nass_carplay_"..v)
            print("Destorying")
        end
        
    end
end)

Citizen.CreateThread(function()
	local doAction = false
	while true do
		Wait(300)
		local ped = PlayerPedId()
		
		if IsPedInAnyVehicle(ped, false) then
			local veh = GetVehiclePedIsIn(ped, false)
			if not doAction then
				doAction = true
				vehicleEntered(veh)
			end
		else
			if doAction then
				doAction = false
			end
		end
	end
end)
