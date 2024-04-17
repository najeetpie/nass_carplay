-----------------For support, scripts, and more----------------
--------------- https://discord.gg/fz655NHeDq  -------------
---------------------------------------------------------------

RegisterNetEvent('nass_carplay:syncmusic')
AddEventHandler('nass_carplay:syncmusic', function(vehNet, data)
    TriggerClientEvent("nass_carplay:playsound", -1, data)
end)
