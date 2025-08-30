local function adminperm(src)
    if Config.Framework == 'esx' then 
        local ESX = exports["es_extended"]:getSharedObject()
        local p = ESX.GetPlayerFromId(src)
        if not p then return false end
        for _, g in ipairs(Config.AdminPerm) do
            if g == p.getGroup() then 
                return true
            end
        end

        return false
    else 
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end

        local perm = Player.PlayerData.permission
        for _, g in ipairs(Config.AdminPerm) do
            if g == perm then
                return true
            end
        end

        return false
    end
end

lib.callback.register('bc:getAdminPerm', function(src)
    return adminperm(src)
end)

lib.callback.register('bc:newblip', function(src, d)
    if not adminperm(src) then return end
    local h = json.decode(LoadResourceFile(GetCurrentResourceName(), 'blips.json'))
    local id = #h+1
    if d.job == "" then 
        d.job = false
    end

    local c = GetEntityCoords(GetPlayerPed(src))

    local newblip = {
        id = id,
        name = d.name,
        sprite = d.sprite,
        colour = d.colour,
        scale = d.scale,
        job = d.job,
        radius = d.radius,
        coords = {x = c.x, y = c.y, z = c.z}
    }
    table.insert(h, newblip)
    SaveResourceFile(GetCurrentResourceName(), 'blips.json', json.encode(h))
end)

lib.callback.register('bc:getJson', function()
    return LoadResourceFile(GetCurrentResourceName(), 'blips.json')
end)

lib.callback.register('bc:deleteblip', function(src, id)
    if not adminperm(src) then return end

    local h = json.decode(LoadResourceFile(GetCurrentResourceName(), 'blips.json'))
    local blipindex = 0

    for i, v in ipairs(h) do
        if v.id == id then 
            blipindex = i
        end
    end

    table.remove(h, blipindex)
    SaveResourceFile(GetCurrentResourceName(), 'blips.json', json.encode(h), -1)
end)

lib.callback.register('bc:saveedit', function(src, d)
    if not adminperm(src) then return end

    local h = json.decode(LoadResourceFile(GetCurrentResourceName(), 'blips.json'))
    for _, v in ipairs(h) do
        if v.id == d.id then 
            v.name = d.name
            v.colour = d.colour
            v.scale = d.scale
            v.sprite = d.sprite
        end
    end
    SaveResourceFile(GetCurrentResourceName(), 'blips.json', json.encode(h), -1)
end)