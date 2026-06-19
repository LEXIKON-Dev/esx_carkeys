ESX = exports['es_extended']:getSharedObject()

local Locale = GetLocale()
local menuOpen = false
local keys = {}

local function L(key, ...)
    local text = Locale.Strings[key]
    if not text then return '' end
    if select('#', ...) > 0 then
        return string.format(text, ...)
    end
    return text
end

local function formatPlate(plate)
    return ('<span style="color: %s;">[%s]</span>'):format(Config.PlateColor, plate)
end

local function notify(key, ...)
    ESX.ShowNotification(L(key, ...))
end

local function menuOpts(title, elements)
    return {
        css = Config.Menu.css,
        title = title,
        align = Config.Menu.align,
        elements = elements,
    }
end

local function openKeyOptions(plate)
    local data = keys[plate]
    if not data then return end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'key_options', menuOpts(
        string.format(Locale.Menu.keyOptionsTitle, formatPlate(plate)),
        {
            { label = Locale.Menu.giveKey, value = 'give' },
            { label = Locale.Menu.removeKey, value = 'remove' },
        }
    ), function(sel, m)
        if sel.current.value == 'give' then
            local target, dist = ESX.Game.GetClosestPlayer()
            if target ~= -1 and dist <= Config.GiveKeyDistance then
                TriggerServerEvent('carkeys:giveKey', GetPlayerServerId(target), plate, data.vehicleName)
                notify('key_given', data.vehicleName, formatPlate(plate))
            else
                notify('no_player_nearby')
            end
        elseif sel.current.value == 'remove' then
            keys[plate] = nil
            TriggerServerEvent('carkeys:removeKey', plate)
            notify('key_removed')
        end
        m.close()
    end, function(_, m) m.close() end)
end

function OpenKeyManagementMenu()
    local list = {}

    for plate, data in pairs(keys) do
        table.insert(list, {
            label = ('%s %s'):format(data.vehicleName, formatPlate(plate)),
            value = plate,
        })
    end

    if #list == 0 then
        table.insert(list, { label = Locale.Menu.noKeys, value = 'none' })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'key_management', menuOpts(
        Locale.Menu.keyMgmtTitle, list
    ), function(sel, m)
        if sel.current.value == 'none' then
            notify('no_keys')
        else
            openKeyOptions(sel.current.value)
        end
    end, function(_, m) m.close() end)
end

function AttemptToStealKeys()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh == 0 then
        notify('must_be_in_vehicle')
        return
    end

    local plate = GetVehicleNumberPlateText(veh)
    local name = GetDisplayNameFromVehicleModel(GetEntityModel(veh))

    keys[plate] = { vehicleName = name }
    TriggerServerEvent('carkeys:stealKeys', plate, name)
    notify('key_stolen', formatPlate(plate))
end

function ToggleVehicleLock()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh = GetVehiclePedIsIn(ped, true)

    if veh == 0 then
        veh = ESX.Game.GetClosestVehicle(coords)
    end

    if veh == 0 then return end

    local vehCoords = GetEntityCoords(veh)
    if #(coords - vehCoords) > Config.LockDistance then return end

    local plate = GetVehicleNumberPlateText(veh)
    if not keys[plate] then
        notify('no_key_for_vehicle')
        return
    end

    local status = GetVehicleDoorLockStatus(veh)
    local netId = NetworkGetNetworkIdFromEntity(veh)
    local anim = Config.Anim

    TaskPlayAnim(ped, anim.dict, anim.clip, anim.blendIn, anim.blendOut, anim.duration, anim.flag, 0, false, false, false)
    TriggerServerEvent('carkeys:playLockSound', netId)

    if status == Config.Lock.unlocked then
        SetVehicleDoorsLocked(veh, Config.Lock.locked)
        PlayVehicleDoorCloseSound(veh, 1)
        notify('vehicle_locked')
        TriggerServerEvent('carkeys:updateLockStatus', plate, true)
    else
        SetVehicleDoorsLocked(veh, Config.Lock.unlocked)
        PlayVehicleDoorOpenSound(veh, 0)
        notify('vehicle_unlocked')
        TriggerServerEvent('carkeys:updateLockStatus', plate, false)
    end
end

CreateThread(function()
    RequestAnimDict(Config.Anim.dict)
    while not HasAnimDictLoaded(Config.Anim.dict) do
        Wait(0)
    end
end)

RegisterCommand(Config.Commands.lock, function()
    ToggleVehicleLock()
end, false)
RegisterKeyMapping(Config.Commands.lock, Locale.KeyLabels.lock, 'keyboard', Config.Keys.lock)

RegisterCommand(Config.Commands.menu, function()
    if menuOpen then return end

    menuOpen = true
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_menu', menuOpts(
        Locale.Menu.mainTitle,
        {
            { label = Locale.Menu.keyMgmt, value = 'mgmt' },
            { label = Locale.Menu.stealKeys, value = 'steal' },
        }
    ), function(sel, m)
        if sel.current.value == 'mgmt' then
            OpenKeyManagementMenu()
        elseif sel.current.value == 'steal' then
            AttemptToStealKeys()
            m.close()
            menuOpen = false
        end
    end, function(_, m)
        m.close()
        menuOpen = false
    end)
end, false)
RegisterKeyMapping(Config.Commands.menu, Locale.KeyLabels.menu, 'keyboard', Config.Keys.menu)

RegisterNetEvent('carkeys:playLockSoundNearby')
AddEventHandler('carkeys:playLockSoundNearby', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(veh) then
        PlaySoundFromEntity(-1, Config.Sound.name, veh, Config.Sound.set, 1, 0)
    end
end)

RegisterNetEvent('carkeys:updateStolenKeys')
AddEventHandler('carkeys:updateStolenKeys', function(newKeys)
    keys = newKeys or {}
end)

RegisterNetEvent('carkeys:receiveJobKey')
AddEventHandler('carkeys:receiveJobKey', function(plate, vehicleName, isJobKey)
    keys[plate] = { vehicleName = vehicleName }

    if isJobKey then
        notify('job_key_received', vehicleName, formatPlate(plate))
    else
        notify('copy_received', vehicleName, formatPlate(plate))
    end
end)

RegisterNetEvent('carkeys:keyExpired')
AddEventHandler('carkeys:keyExpired', function(plate)
    if not keys[plate] then return end

    local name = keys[plate].vehicleName or plate
    keys[plate] = nil
    notify('key_expired', name, formatPlate(plate))
end)
