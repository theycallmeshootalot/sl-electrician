local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('sl-electrician:server:apply', function()
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)

    if #(GetEntityCoords(GetPlayerPed(src)) - vector3(Config.ManagerLocation.x, Config.ManagerLocation.y, Config.ManagerLocation.z)) < 3 then 
        if Player.PlayerData.job.name ~= Config.JobName then
            Player.Functions.SetJob(Config.JobName, 0)
        end
    else
        TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'sl_electrician', 'red', '**FiveM Identifier**: `'..GetPlayerName(src) .. '` \n**Character Name**: `'..Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname ..'`\n**CSN**: `'..Player.PlayerData.citizenid..'`\n**ID**: `'..src..'`\n**License**: `'..Player.PlayerData.license.."`\n\n **Detection of an event being triggered for attempting to set the players job to `"..Config.JobName.."` whilst this player being out of range**", true)
        DropPlayer(src, "You were removed for the detection of cheating (sl-electrician), if you believe this was a mistake contact Server Administration.")
    end
end)

RegisterNetEvent('sl-electrician:server:quit', function()
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    if #(GetEntityCoords(GetPlayerPed(src)) - vector3(Config.ManagerLocation.x, Config.ManagerLocation.y, Config.ManagerLocation.z)) < 3 then 
        if Player.PlayerData.job.name == Config.JobName then
            Player.Functions.SetJob(Config.CivilianJobName, 0)
        end
    else
        TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'sl_electrician', 'red', '**FiveM Identifier**: `'..GetPlayerName(src) .. '` \n**Character Name**: `'..Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname ..'`\n**CSN**: `'..Player.PlayerData.citizenid..'`\n**ID**: `'..src..'`\n**License**: `'..Player.PlayerData.license.."`\n\n **Detection of an event being triggered for attempting to remove the players job from `"..Config.JobName.."` to `"..Config.CivilianJobName.."` whilst this player being out of range**", true)
        DropPlayer(src, "You were removed for the detection of cheating (sl-electrician), if you believe this was a mistake contact Server Administration.")
    end
end)

RegisterNetEvent('sl-electrician:server:payment', function(work)
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    local payment = math.random(Config.MinimumPayment, Config.MaximumPayment)
    coords = work

    if #(GetEntityCoords(GetPlayerPed(src)) - coords) < 3 then 
        if Player.PlayerData.job.name == "electrician" then
            Player.Functions.AddMoney("bank", payment, "electrician-payment")
            TriggerClientEvent('QBCore:Notify', src, "You were paid $"..payment.." for completing a task", "info")
        end
    else
        TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'sl_electrician', 'red', '**FiveM Identifier**: `'..GetPlayerName(src) .. '` \n**Character Name**: `'..Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname ..'`\n**CSN**: `'..Player.PlayerData.citizenid..'`\n**ID**: `'..src..'`\n**License**: `'..Player.PlayerData.license.."`\n\n **Detection of an event being triggered for attempting to give the player money with the amount of `$"..payment.."` whilst this player being out of range of a task location**", true)
        DropPlayer(src, "You were removed for the detection of cheating (sl-electrician), if you believe this was a mistake contact Server Administration.")
    end
end)