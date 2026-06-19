local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local keyHolders = {}

local function trimPlate(plate)
    return plate:gsub('%s+', '')
end

local function addKey(src, plate)
    if not keyHolders[plate] then
        keyHolders[plate] = {}
    end
    keyHolders[plate][src] = true
end

local function removeKey(src, plate)
    local holders = keyHolders[plate]
    if not holders then return end

    holders[src] = nil
    if not next(holders) then
        keyHolders[plate] = nil
    end
end

local function clearPlayerKeys(src)
    for plate, holders in pairs(keyHolders) do
        holders[src] = nil
        if not next(holders) then
            keyHolders[plate] = nil
        end
    end
end

RegisterNetEvent('carkeys:stealKeys')
AddEventHandler('carkeys:stealKeys', function(plate, vehicleName)
    addKey(source, plate)
end)

RegisterNetEvent('carkeys:removeKey')
AddEventHandler('carkeys:removeKey', function(plate)
    removeKey(source, plate)
end)

RegisterNetEvent('carkeys:giveKey')
AddEventHandler('carkeys:giveKey', function(targetSrc, plate, vehicleName)
    if not GetPlayerName(targetSrc) then return end

    addKey(targetSrc, plate)
    TriggerClientEvent('carkeys:receiveJobKey', targetSrc, plate, vehicleName, false)
end)

-- TriggerServerEvent('carkeys:giveJobKey', targetSrc, plate, vehicleName)
RegisterNetEvent('carkeys:giveJobKey')
AddEventHandler('carkeys:giveJobKey', function(targetSrc, plate, vehicleName)
    if not GetPlayerName(targetSrc) then return end

    addKey(targetSrc, plate)
    TriggerClientEvent('carkeys:receiveJobKey', targetSrc, plate, vehicleName, true)
end)

AddEventHandler('playerDropped', function()
    clearPlayerKeys(source)
end)

RegisterNetEvent('carkeys:playLockSound')
AddEventHandler('carkeys:playLockSound', function(vehicleNetId)
    TriggerClientEvent('carkeys:playLockSoundNearby', -1, vehicleNetId)
end)

RegisterNetEvent('carkeys:updateLockStatus')
AddEventHandler('carkeys:updateLockStatus', function(plate, isLocked)
end)

CreateThread(function()
    while true do
        Wait(Config.DespawnCheckInterval)

        local spawned = {}
        for _, veh in ipairs(GetAllVehicles()) do
            if DoesEntityExist(veh) then
                local plate = GetVehicleNumberPlateText(veh)
                if plate and plate ~= '' then
                    spawned[trimPlate(plate)] = true
                end
            end
        end

        for plate, holders in pairs(keyHolders) do
            if not spawned[trimPlate(plate)] then
                for src in pairs(holders) do
                    TriggerClientEvent('carkeys:keyExpired', src, plate)
                end
                keyHolders[plate] = nil
            end
        end
    end
end)
