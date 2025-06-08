
local RSGCore = exports['rsg-core']:GetCoreObject()

local spawnedNPCs = {}
local insideZone = false
local createdZones = {}

local function CreateLocationTriggers()
    for locationName, locationData in pairs(Config.BountyLocation) do
       
        local centerCoord = locationData.coords[1]
        
       
        lib.zones.sphere({
            coords = centerCoord,
            radius = 50.0,
            debug = Config.Debug,
            inside = function()
                if not insideZone then
                    insideZone = true
                   
                    local currentHour = GetClockHours()
                    TriggerServerEvent('rsg-ufo:server:checkAreaTrigger', locationName, locationData, currentHour)
                end
            end,
            onExit = function()
                insideZone = false
            end
        })
    end
end


CreateThread(function()
    CreateLocationTriggers()
end)

CreateThread(function()
    Wait(2000) 
    CreateLocationTriggers()
end)


CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        local currentHour = GetClockHours()
        TriggerServerEvent('rsg-ufo:server:checkTimeRestriction', currentHour)
    end
end)

RegisterNetEvent('rsg-ufo:client:checkBountyBoard')
AddEventHandler('rsg-ufo:client:checkBountyBoard', function()
    RSGCore.Functions.Progressbar("check_bounty", "Checking Bounties...", 5000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() 
       
        local currentHour = GetClockHours()
        TriggerServerEvent('rsg-ufo:server:requestMission', currentHour)
    end, function()
    end)
end)

function SpawnBountyNPCs(location)
    spawnedNPCs = {}
  
    local playerGroup = GetHashKey("PLAYER")
    local enemyGroup = GetHashKey("HATES_PLAYER")
    AddRelationshipGroup("HATES_PLAYER")
    SetRelationshipBetweenGroups(5, enemyGroup, playerGroup)
    SetRelationshipBetweenGroups(5, playerGroup, enemyGroup)
    
   
    local npcDamageMultiplier = 20.0 

    for i, coords in pairs(location.data.coords) do
        local modelInfo = Config.models[math.random(#Config.models)]
        local weaponInfo = Config.weapons[math.random(#Config.weapons)]
        
        local modelHash = GetHashKey(modelInfo.hash)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(10)
        end
        
        local npc = CreatePed(modelHash, coords.x, coords.y, coords.z, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        
        
        local maxHealth = 100
        local startingHealth = 100
        Citizen.InvokeNative(0xAC2767ED8BDFAB15, npc, maxHealth, 0)
        Citizen.InvokeNative(0x6B76DC1F3AE6E6A3, npc, startingHealth)
        
       
        GiveWeaponToPed_2(npc, weaponInfo.hash, 50, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
        
       
        SetPedRelationshipGroupHash(npc, enemyGroup)
        SetPedCombatAttributes(npc, 3, true)
        SetPedCombatAttributes(npc, 5, true)
        SetPedCombatAttributes(npc, 2, true)
        SetPedCombatMovement(npc, 2)
        SetPedCombatRange(npc, 2)
        SetPedAccuracy(npc, 90)
        SetPedShootRate(npc, 200)
     
        Citizen.InvokeNative(0x697F508861875B42, npc, npcDamageMultiplier) -- SetPedDamage

        TaskCombatPed(npc, PlayerPedId(), 0, 16)
        local npcNetId = NetworkGetNetworkIdFromEntity(npc)
        TriggerServerEvent('rsg-ufo:server:registerNPC', npcNetId)
        
        table.insert(spawnedNPCs, npc)
        
       
        local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 0x318C617C, npc)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Hostile")
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, GetHashKey("BLIP_MODIFIER_MP_COLOR_8"))
        Citizen.InvokeNative(0x931B241409216C1F, npc, blip, true)
        SetBlipScale(blip, 0.8)
        
       
        CreateThread(function()
            while true do
                Wait(500)
                if IsEntityDead(npc) then
                    local npcNetId = NetworkGetNetworkIdFromEntity(npc)
                    TriggerServerEvent('rsg-ufo:server:npcKilled', npcNetId)
                    if DoesBlipExist(blip) then
                        RemoveBlip(blip)
                    end
                    break
                end
            end
        end)
    end
end


AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
    TriggerServerEvent('rsg-ufo:server:playerDied')
end)

RegisterNetEvent('rsg-ufo:client:spawnNPCs')
AddEventHandler('rsg-ufo:client:spawnNPCs', function(location)
    SpawnBountyNPCs(location)
end)

RegisterNetEvent('rsg-ufo:client:startMission')
AddEventHandler('rsg-ufo:client:startMission', function(location)
    local centerCoord = location.data.coords[1]
    local missionBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, centerCoord.x, centerCoord.y, centerCoord.z)
    SetBlipSprite(missionBlip, -1103135225, true)
    SetBlipScale(missionBlip, Config.BlipBounty.blipScale)
    Citizen.InvokeNative(0x9CB1A1623062F402, missionBlip, Config.BlipBounty.blipName)
end)

RegisterNetEvent('rsg-ufo:client:missionComplete')
AddEventHandler('rsg-ufo:client:missionComplete', function()
    for _, npc in pairs(spawnedNPCs) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end
    spawnedNPCs = {}

    TriggerEvent('rNotify:NotifyLeft', "Mission Complete", 
        "All targets have been eliminated", 
        "generic_textures", "tick", 5000, "COLOR_GREEN")
end)
