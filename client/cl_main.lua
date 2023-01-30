local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

local isDoingJob = false

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then 
        PlayerJob = QBCore.Functions.GetPlayerData().job 
        ElectricianApply()
    end
end)


AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    ElectricianApply()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

CreateThread(function()
    local blip = AddBlipForCoord(Config.ManagerLocation.x, Config.ManagerLocation.y, Config.ManagerLocation.y)
    SetBlipSprite(blip, 459)
    SetBlipColour(blip, 43)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Electrician Headquarters")
    EndTextCommandSetBlipName(blip)
end)

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        isDoingJob = false
        RemoveBlip(blip)
        exports['qb-radialmenu']:RemoveOption(radialmenut)
        exports['qb-radialmenu']:RemoveOption(radialmenuet)
        exports['qb-target']:RemoveZone("electricboxes")
	end 
end)

function ElectricianApply()
    if not DoesEntityExist(electricianmodel) then

        RequestModel(Config.ManagerPed)
        while not HasModelLoaded(Config.ManagerPed) do
            Wait(0)
        end

        electricianmodel = CreatePed(1, Config.ManagerPed, Config.ManagerLocation.x, Config.ManagerLocation.y, Config.ManagerLocation.y, Config.ManagerLocation.w, false, false)
        TaskStartScenarioInPlace(electricianmodel, "WORLD_HUMAN_CLIPBOARD", 0, true)
        SetEntityAsMissionEntity(electricianmodel)
        SetBlockingOfNonTemporaryEvents(electricianmodel, true)
        SetEntityInvincible(electricianmodel, true)
        FreezeEntityPosition(electricianmodel, true)

        exports['qb-target']:AddTargetEntity(electricianmodel, {
            options = {
                {
                    type = "client",
                    event = "sl-electrician:client:apply",
                    icon = "fa-solid fa-clipboard",
                    label = "Apply For Job",
                    canInteract = function()
                        if PlayerJob.name == Config.JobName then return false end 
                        return true 
                    end,
                },
                {
                    num = 1,
                    type = "client",
                    event = "sl-electrician:client:requestwork",
                    icon = "fa-solid fa-car",
                    label = "Request Work Vehicle",
                    job = Config.JobName
                },
                {
                    num = 2,
                    type = "client",
                    event = "sl-electrician:client:quit",
                    icon = "fa-solid fa-x",
                    label = "Quit Job",
                    job = Config.JobName
                }
            },
            distance = 2.5,
        })
    end
end

RegisterNetEvent('sl-electrician:client:apply', function()
    if PlayerJob.name ~= Config.JobName then 
        ClearPedTasksImmediately(PlayerPedId())
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CLIPBOARD", 0, true)
        QBCore.Functions.Progressbar('electrician_apply', 'Filling Out Documents', 10000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            ClearPedTasks()
            TriggerServerEvent('sl-electrician:server:apply')
            QBCore.Functions.Notify('You were hired to work as a Electrician, you are to repair electric boxes.', 'success')
        end, function()
            ClearPedTasks()
            QBCore.Functions.Notify('You failed to process to apply as a Electrician.', 'error')
        end)
    end
end)

RegisterNetEvent('sl-electrician:client:quit', function()
    if PlayerJob.name == Config.JobName then 
        ClearPedTasksImmediately(PlayerPedId())
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CLIPBOARD", 0, true)
        QBCore.Functions.Progressbar('electrician_apply', 'Quitting Job', 10000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            ClearPedTasks()
            TriggerServerEvent('sl-electrician:server:quit')
            QBCore.Functions.Notify('You have successfully quit your job.', 'success')
        end, function()
            ClearPedTasks()
            QBCore.Functions.Notify('You failed to process to quit your job.', 'error')
        end)
    end
end)

RegisterNetEvent('sl-electrician:client:repair', function()
    if isDoingJob == true then
        TriggerEvent('animations:client:EmoteCommandStart', {"hammer"})
        QBCore.Functions.Progressbar("city_repair", "Removing Panel", 10000, false, false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
            QBCore.Functions.Progressbar("city_repair", "Repairing Electric Box", 10000, false, false, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                TriggerEvent('animations:client:EmoteCommandStart', {"hammer"})
                QBCore.Functions.Progressbar("city_repair", "Attaching Panel", 10000, false, false, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    exports['qb-target']:RemoveZone("electricboxes")
                    RemoveBlip(TaskBlip)
                    isDoingJob = false
                    TriggerServerEvent('sl-electrician:server:payment', work)
                end)
            end)
        end)
    end
end)

RegisterNetEvent('sl-electrician:client:task', function()
    if isDoingJob == false then 
        isDoingJob = true
        work = Config.TaskLocations[math.random(1, #Config.TaskLocations)]
        QBCore.Functions.Notify("You have given a new task to complete", "info")

        TaskBlip = AddBlipForCoord(work.x, work.y, work.z)
        SetBlipSprite(TaskBlip, 566)
        SetBlipColour(TaskBlip, 43)
        SetBlipRoute(TaskBlip, true)
        SetBlipRouteColour(TaskBlip, 43)
        SetBlipScale(TaskBlip, 0.9)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Task")
        EndTextCommandSetBlipName(TaskBlip)
        exports['qb-target']:AddCircleZone("electricboxes", vector3(work.x, work.y, work.z), 1.3,{ 
            name = "electricboxes", 
            debugPoly = false, 
            useZ=true, 
        }, { 
            options = { 
                { 
                    type = "client", 
                    event = "sl-electrician:client:repair",
                    icon = "fa-solid fa-hammer", 
                    label = "Repair Electric Box", 
                    job = Config.JobName
                }, 
            }, 
            distance = 2.5 })
    else
        QBCore.Functions.Notify("You have to end your current task before getting a new one", "error")
    end
end)

RegisterNetEvent('sl-electrician:client:endtask', function()
    if isDoingJob == true then 
        RemoveBlip(TaskBlip)
        isDoingJob = false
        QBCore.Functions.Notify("You have successfully ended your task", "success")
    else
        QBCore.Functions.Notify("You do not have an active task", "error")
    end
end)

RegisterNetEvent('sl-electrician:client:requestwork', function()
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        SetVehicleNumberPlateText(veh, "WORK "..math.random(100,999))
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        QBCore.Functions.GetPlate(veh)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
    end, Config.WorkVehicle, Config.WorkVehicleSpawnCoords, true)

    
    radialmenut = exports['qb-radialmenu']:AddOption({
        id = 'gopostal',
        title = 'Get Task',
        icon = 'hammer',
        type = 'client',
        event = 'sl-electrician:client:task',
        shouldClose = true
    })

    radialmenuet = exports['qb-radialmenu']:AddOption({
        id = 'gopostal',
        title = 'End Task',
        icon = 'x',
        type = 'client',
        event = 'sl-electrician:client:endtask',
        shouldClose = true
    })
end)
