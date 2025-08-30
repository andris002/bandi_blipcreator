local function open()
    SendNUIMessage({
        type = 'open',
        jobs = Config.JobIcons
    })    
    SetNuiFocus(true, true)
end

local function GetJob()
    if Config.Framework == 'esx' then 
        local ESX = exports["es_extended"]:getSharedObject()
        return ESX.PlayerData.job.name
    else 
        local QBCore = exports['qb-core']:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.job.name
    end
end

RegisterCommand('blipcreator', function()
    local admin = lib.callback.await('bc:getAdminPerm', false)
    if admin then open() end
end, false)

RegisterNuiCallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNuiCallback('createblip', function(d, cb)
    lib.callback.await('bc:newblip', false, d)
    cb('ok')
end)

RegisterNuiCallback('getJSON', function(_, cb)
    local l = lib.callback.await('bc:getJson', false)
    cb(l)
end)

RegisterNuiCallback('tpcoord', function(c, cb)
    SetEntityCoords(PlayerPedId(), c.x, c.y, c.z, false, false, false, false)
    cb('ok')
end)

RegisterNuiCallback('getspritename', function(name, cb)
    cb(GetBlipSpriteName(name))
end)

RegisterNuiCallback('GetBlipColor', function(c, cb)
    cb(GetBlipColorHash(c))
end)

RegisterNuiCallback('deleteblip', function(id, cb)
    lib.callback.await('bc:deleteblip', false, id)
    cb('ok')
end)

RegisterNuiCallback('save', function(d, cb)
    lib.callback.await('bc:saveedit', false, d)
    cb('ok')
end)

RegisterKeyMapping('blipcreator', 'Open Blip Creator', 'keyboard', 'f3')

local blips = {}

CreateThread(function()
    while true do
        local f = lib.callback.await('bc:getJson', false)
        local data = json.decode(f)

        local activeIds = {}

        for _, v in ipairs(data) do
            activeIds[v.id] = true 

            if blips[v.id] then
                if blips[v.id].b then RemoveBlip(blips[v.id].b) end
                if blips[v.id].r then RemoveBlip(blips[v.id].r) end
                blips[v.id] = nil
            end
            if not v.job or (GetJob() == v.job) then

                local c = v.coords
                local blip = AddBlipForCoord(c.x, c.y, c.z)
                SetBlipSprite(blip, v.sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, v.scale == 1 and v.scale + 0.0 or v.scale)
                SetBlipColour(blip, v.colour)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.name)
                EndTextCommandSetBlipName(blip)

                local radius
                if v.radius then
                    radius = AddBlipForRadius(c.x, c.y, c.z, v.radius + 0.0)
                    SetBlipAlpha(radius, 80)
                    SetBlipColour(radius, v.colour)
                end

                blips[v.id] = { b = blip, r = radius }
            end
        end

        for id, blip in pairs(blips) do
            if not activeIds[id] then
                if blip.b then RemoveBlip(blip.b) end
                if blip.r then RemoveBlip(blip.r) end
                blips[id] = nil
            end
        end

        Wait(10000)
    end
end)

