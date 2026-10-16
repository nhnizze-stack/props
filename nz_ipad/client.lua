-- Hold an iPad: ox_inventory items 'ipad' (Space Black) and 'ipad_silver' call exports['nz-ipad']:use.
-- Using it again, pressing X, dying or getting into a vehicle puts it away.
local MODELS = { ipad = `nz_ipad_black`, ipad_silver = `nz_ipad_silver` }
-- both hands in front of the chest, screen towards the player (the classic "tablet" emote);
-- the model has prop_cs_tablet's frame, so that emote's offset fits
local DICT, ANIM = 'amb@world_human_tourist_map@male@base', 'base'
local BONE, POS, ROT = 28422, vec3(0.0, -0.03, 0.0), vec3(20.0, -90.0, 0.0)

local prop, holding = nil, false

local function load(request, has, asset)
    request(asset)
    local t = GetGameTimer() + 5000
    while not has(asset) do
        if GetGameTimer() > t then return false end
        Wait(0)
    end
    return true
end

local function putAway()
    holding = false
    local ped = PlayerPedId()
    if prop and DoesEntityExist(prop) then
        DetachEntity(prop, true, false)
        DeleteEntity(prop)
    end
    prop = nil
    StopAnimTask(ped, DICT, ANIM, 1.0)
end

local function hold(model)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then return end
    if not load(RequestModel, HasModelLoaded, model) or not load(RequestAnimDict, HasAnimDictLoaded, DICT) then return end
    local c = GetEntityCoords(ped)
    prop = CreateObject(model, c.x, c.y, c.z + 0.2, true, true, false)
    SetEntityCollision(prop, false, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, BONE), POS.x, POS.y, POS.z, ROT.x, ROT.y, ROT.z, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)
    TaskPlayAnim(ped, DICT, ANIM, 3.0, 3.0, -1, 49, 0.0, false, false, false)
    holding = true
    CreateThread(function()
        local started = GetGameTimer()
        while holding do
            ped = PlayerPedId()
            -- another emote, the emote cancel key or a ragdoll ends the animation: drop the prop with it
            local lost = GetGameTimer() - started > 1000 and not IsEntityPlayingAnim(ped, DICT, ANIM, 3)
            if lost or IsEntityDead(ped) or IsPedInAnyVehicle(ped, true) or IsControlJustPressed(0, 73) then
                putAway()
                break
            end
            Wait(0)
        end
    end)
end

local function toggle(item)
    if holding then return putAway() end
    hold(MODELS[item] or MODELS.ipad)
end

--- ox_inventory: client = { export = 'nz-ipad.use' }
exports('use', function(data) toggle(data and data.name) end)

-- put it away if the item leaves the inventory while holding it
AddEventHandler('ox_inventory:itemCount', function(item, count)
    if holding and MODELS[item] and count == 0 then putAway() end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and holding then putAway() end
end)

-- tuning while holding: /ipadpos x y z rx ry rz  (no arguments prints the current values)
RegisterCommand('ipadpos', function(_, a)
    if #a >= 6 then
        POS = vec3(tonumber(a[1]) or 0.0, tonumber(a[2]) or 0.0, tonumber(a[3]) or 0.0)
        ROT = vec3(tonumber(a[4]) or 0.0, tonumber(a[5]) or 0.0, tonumber(a[6]) or 0.0)
        if prop and DoesEntityExist(prop) then
            local ped = PlayerPedId()
            AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, BONE), POS.x, POS.y, POS.z, ROT.x, ROT.y, ROT.z, true, true, false, true, 1, true)
        end
    end
    print(('ipadpos %.3f %.3f %.3f %.1f %.1f %.1f'):format(POS.x, POS.y, POS.z, ROT.x, ROT.y, ROT.z))
end, false)
