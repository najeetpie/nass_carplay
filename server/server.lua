-----------------For support, scripts, and more----------------
--------------- https://discord.gg/fz655NHeDq  -------------
---------------------------------------------------------------

RegisterNetEvent('nass_carplay:syncmusic')
AddEventHandler('nass_carplay:syncmusic', function(peds, vehNet, data)
    local veh = NetworkGetEntityFromNetworkId(vehNet)
	if veh ~= 0 then
        for k, v in pairs(peds) do
            TriggerClientEvent("nass_carplay:playsound", v, data)
        end
	end
end)
