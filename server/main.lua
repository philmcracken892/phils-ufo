local RSGCore = exports['rsg-core']:GetCoreObject()
local activeNPCs = {}
local activeMission = false
local deadNPCs = 0
local totalNPCs = 0
local missionLocation = nil
local spawningPlayer = nil
local lastMissionTime = 0  
local cooldownDuration = 600  
local registeredNPCs = {}


local function IsWithinAllowedHours(hour)
    
    return (hour >= 22) or (hour <= 3)
end

local function GetPlayersInRange(coords, range)
    local players = GetPlayers()
    local playersInRange = {}
    
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed then
            local targetCoords = GetEntityCoords(targetPed)
          
            local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(targetCoords.x, targetCoords.y, targetCoords.z))
            
            if distance <= range then
                table.insert(playersInRange, playerId)
            end
        end
    end
    
    return playersInRange
end

local function GetRandomLocation()
    local locations = {}
    for k, v in pairs(Config.BountyLocation) do
        table.insert(locations, {name = k, data = v})
    end
    return locations[math.random(#locations)]
end

RegisterServerEvent('rsg-ufo:server:checkAreaTrigger')
AddEventHandler('rsg-ufo:server:checkAreaTrigger', function(locationName, locationData, currentHour)
    local currentTime = os.time()
    
   
    if not IsWithinAllowedHours(currentHour) then
        TriggerClientEvent('rNotify:NotifyLeft', source, "Bounty Alert", 
            " missions are only available between 22:00 and 03:00 ", 
            "generic_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    if activeMission then
        TriggerClientEvent('rNotify:NotifyLeft', source, "Alert", 
            "There's already an active  mission", 
            "generic_textures", "cross", 4000, "COLOR_RED")
        return
    elseif currentTime < lastMissionTime + cooldownDuration then
        local remainingTime = (lastMissionTime + cooldownDuration) - currentTime
        TriggerClientEvent('rNotify:NotifyLeft', source, "Alert", 
            "Area in cooldown for " .. math.ceil(remainingTime / 60) .. " minutes before bounties are available", 
            "generic_textures", "cross", 4000, "COLOR_RED")
        return
    end

    activeMission = true
    missionLocation = {name = locationName, data = locationData}
    totalNPCs = #locationData.coords
    deadNPCs = 0
    spawningPlayer = source

    TriggerClientEvent('rsg-ufo:client:startMission', -1, missionLocation)
    TriggerClientEvent('rNotify:NotifyLeft', -1, "Alert", 
        "beings spotted at " .. locationName .. "\n" .. locationData.description, 
        "generic_textures", "tick", 8000, "COLOR_WHITE")
        
    TriggerClientEvent('rsg-ufo:client:spawnNPCs', source, missionLocation)
    lastMissionTime = currentTime
end)

local function ReassignMissionIfNeeded()
    local players = GetPlayers()
    if #players > 0 then
        spawningPlayer = players[1]
        
        TriggerClientEvent('rNotify:NotifyLeft', -1, "Bounty Update", 
            "The player responsible for the mission is unavailable. Reassigning tasks.", 
            "generic_textures", "tick", 5000, "COLOR_WHITE")
        
        TriggerClientEvent('rsg-ufo:client:spawnNPCs', spawningPlayer, missionLocation)
    else
        activeMission = false
        TriggerClientEvent('rNotify:NotifyLeft', -1, "Bounty Canceled", 
            "mission canceled as no players are left to complete the task.", 
            "generic_textures", "cross", 5000, "COLOR_RED")
    end
end

local function StartBountyMission(currentHour)
    local currentTime = os.time()
    
    
    if not IsWithinAllowedHours(currentHour) then
        return
    end
    
    if activeMission then
        return
    elseif currentTime < lastMissionTime + cooldownDuration then
        return
    end
    
    activeMission = true
    deadNPCs = 0
    activeNPCs = {}

    local location = GetRandomLocation()
    missionLocation = location
    totalNPCs = #location.data.coords

    local players = GetPlayers()
    if #players > 0 then
        spawningPlayer = players[1]

       
        local centerCoord = location.data.coords[1]
        
       
        Citizen.CreateThread(function()
            Wait(1000) 
            local nearbyPlayers = GetPlayersInRange(centerCoord, 100.0)
            
           
            for _, playerId in ipairs(nearbyPlayers) do
                if tonumber(playerId) ~= tonumber(spawningPlayer) then 
                    local Player = RSGCore.Functions.GetPlayer(tonumber(playerId))
                    if Player then
                        Player.Functions.AddMoney('cash', 150, "bounty-nearby-reward")
                        TriggerClientEvent('rNotify:NotifyLeft', playerId, "Bonus", 
                            "You received $150 for being near the bounty area!", 
                            "generic_textures", "tick", 4000, "COLOR_GREEN")
                    end
                end
            end
        end)

       
        TriggerClientEvent('rsg-ufo:client:startMission', -1, location)
        TriggerClientEvent('rNotify:NotifyLeft', -1, "Bounty Alert", 
            "Wanted beings spotted at " .. location.name .. "\n" .. location.data.description, 
            "generic_textures", "tick", 8000, "COLOR_WHITE")

        TriggerClientEvent('rsg-ufo:client:spawnNPCs', spawningPlayer, location)
        lastMissionTime = currentTime
    end
end

RegisterServerEvent('rsg-ufo:server:requestMission')
AddEventHandler('rsg-ufo:server:requestMission', function(currentHour)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
   
    if not IsWithinAllowedHours(currentHour) then
        local nextAvailableTime = ""
        if currentHour < 22 and currentHour > 3 then
            nextAvailableTime = "22:00 tonight"
        else
            nextAvailableTime = "after 22:00"
        end
        
        TriggerClientEvent('rNotify:NotifyLeft', src, "Board", 
            "Bounty missions are only available between 22:00 and 03:00 . Next available: " .. nextAvailableTime, 
            "generic_textures", "cross", 6000, "COLOR_RED")
        return
    end
    
   
    local currentTime = os.time()
    if activeMission then
        TriggerClientEvent('rNotify:NotifyLeft', src, "Bounty Board", 
            "There's already an active  mission", 
            "generic_textures", "cross", 4000, "COLOR_RED")
        return
    elseif currentTime < lastMissionTime + cooldownDuration then
        local remainingTime = (lastMissionTime + cooldownDuration) - currentTime
        TriggerClientEvent('rNotify:NotifyLeft', src, "Board", 
            "Bounties will be available in " .. math.ceil(remainingTime / 60) .. " minutes", 
            "generic_textures", "cross", 4000, "COLOR_RED")
        return
    end

   
    StartBountyMission(currentHour)
    TriggerClientEvent('rNotify:NotifyLeft', src, "Bounty Board", 
        "You've accepted a new bounty mission", 
        "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

RegisterServerEvent('rsg-ufo:server:registerNPC')
AddEventHandler('rsg-ufo:server:registerNPC', function(npcNetId)
    activeNPCs[npcNetId] = true
end)

RegisterServerEvent('rsg-ufo:server:npcKilled')
AddEventHandler('rsg-ufo:server:npcKilled', function(npcNetId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if activeNPCs[npcNetId] then
        activeNPCs[npcNetId] = nil
        deadNPCs = deadNPCs + 1
        
       
        local reward = Config.Price or math.random(50, 150)
        Player.Functions.AddMoney('cash', reward, "bounty-reward")
        
        TriggerClientEvent('rNotify:NotifyLeft', src, "Collected", 
            "You received $" .. reward .. " for eliminating the target", 
            "generic_textures", "tick", 4000, "COLOR_GREEN")
        
       
        local centerCoord = missionLocation.data.coords[1]
        local nearbyPlayers = GetPlayersInRange(centerCoord, 100.0)
        
       
        local assistReward = 75 
        for _, playerId in ipairs(nearbyPlayers) do
            if tonumber(playerId) ~= tonumber(src) then 
                local NearbyPlayer = RSGCore.Functions.GetPlayer(tonumber(playerId))
                if NearbyPlayer then
                    NearbyPlayer.Functions.AddMoney('cash', assistReward, "bounty-assist-reward")
                    TriggerClientEvent('rNotify:NotifyLeft', playerId, "Assist", 
                        "You received $" .. assistReward .. " for assisting with the kill!", 
                        "generic_textures", "tick", 4000, "COLOR_GREEN")
                end
            end
        end
        
       
        if deadNPCs >= totalNPCs then
          
            for _, playerId in ipairs(nearbyPlayers) do
                if tonumber(playerId) ~= tonumber(src) then 
                    local NearbyPlayer = RSGCore.Functions.GetPlayer(tonumber(playerId))
                    if NearbyPlayer then
                        local completionBonus = 75  
                        NearbyPlayer.Functions.AddMoney('cash', completionBonus, "bounty-completion-bonus")
                        TriggerClientEvent('rNotify:NotifyLeft', playerId, "Mission Complete", 
                            "You received an additional $" .. completionBonus .. " for helping complete the mission!", 
                            "generic_textures", "tick", 4000, "COLOR_GREEN")
                    end
                end
            end

            TriggerClientEvent('rsg-ufo:client:missionComplete', -1)
            activeMission = false
            lastMissionTime = os.time() 
        end
    end
end)


RegisterServerEvent('rsg-ufo:server:checkTimeRestriction')
AddEventHandler('rsg-ufo:server:checkTimeRestriction', function(currentHour)
    if activeMission and not IsWithinAllowedHours(currentHour) then
       
        TriggerClientEvent('rNotify:NotifyLeft', -1, "Mission Ended", 
            "Bounty mission has ended as it's now outside allowed hours (22:00-03:00 )", 
            "generic_textures", "cross", 6000, "COLOR_RED")
        TriggerClientEvent('rsg-ufo:client:missionComplete', -1)
        activeMission = false
    end
end)
