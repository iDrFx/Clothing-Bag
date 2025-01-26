local QBCore = exports['qb-core']:GetCoreObject()
local Bags = {}

-- EventHandler
AddEventHandler('onResourceStart', function(resource)
    if resource == cache.resource then
        exports['qb-core']:AddItem(Config.item.name, {
            name = Config.item.name,
            label = Config.item.label,
            weight = Config.item.weight,
            type = "item",
            image = Config.item.image,
            unique = Config.item.unique,
            useable = true,
            shouldClose = true,
            combinable = "nil",
            description = Config.item.description,
        })
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        exports['qb-core']:RemoveItem(Config.item.name)
        for obj, _ in pairs(Bags) do
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            end
        end
    end
end)

-- Functions
local function SpawnObject(source, model, coords)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local heading = coords.w and coords.w or 0.0
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(obj, heading)
    while not DoesEntityExist(obj) do Wait(0) end
    while NetworkGetEntityOwner(obj) ~= source do Wait(0) end
    return obj, NetworkGetNetworkIdFromEntity(obj)
end

local function EditItemMetadata(src, slot)
    local Player = QBCore.Functions.GetPlayer(src)
    local Items = Player.PlayerData.items
    if not slot then return end
    local Bag = exports['qb-inventory']:GetItemBySlot(src, slot)
    if Bag then 
        if Bag.slot == slot then 
            if not Items[Bag.slot] then DropPlayer(src, 'Not Today, Maybe Tomorrow') return false end
            if Items[Bag.slot].info and Items[slot].info.uses then 
                if Items[Bag.slot].info.uses > 0 then 
                    Items[Bag.slot].info.uses -= 1
                    if Items[Bag.slot].info.uses <= 0 then 
                        Items[Bag.slot].info.uses = 0 
                    end
                    exports['qb-inventory']:SetInventory(src, Items)
                    return true
                end
            elseif Items[Bag.slot].info and Items[Bag.slot].info.uses == nil then
                Items[Bag.slot].info.uses = Config.uses - 1
                exports['qb-inventory']:SetInventory(src, Items)
                return true
            end
        else
            DropPlayer(src, 'Not Today, Maybe Tomorrow')
            return false
        end
    end
    return false
end

-- Callback
lib.callback.register('qb-clothingbag/cb/spawnobject', function(source, model, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local obj, netid = SpawnObject(src, model, coords)
    Bags[obj] = true

    SetTimeout(Config.despawn * 1000 * 60, function()
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
            Bags[obj] = nil
        end
    end)

    return obj, netid
end)

-- Events
RegisterNetEvent("qb-clothingbag/sv/takebag", function(netid, uses)
    local entity = NetworkGetEntityFromNetworkId(netid)
    if not DoesEntityExist(entity) then return end
    DeleteEntity(entity)
end)

RegisterNetEvent("qb-clothingbag/sv/addinteracrt", function(netid, uses)
   TriggerClientEvent('qb-clothingbag/cl/addinteracrt', -1, netid, uses)
end)

-- CreateUseableItem
QBCore.Functions.CreateUseableItem(Config.item.name, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local CanUse = EditItemMetadata(src, item.slot)
    if CanUse then
        Player = QBCore.Functions.GetPlayer(src)
        local Bagitem = exports['qb-inventory']:GetItemBySlot(src, item.slot)
        TriggerClientEvent('qb-clothingbag/cl/usebag', src, Bagitem.info.uses)
    end
end)

-- Commands
lib.addCommand('clothingbag', {
    help = "spawn clothing bad (admin)",
    restricted = 'group.admin'
}, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    TriggerClientEvent('qb-clothingbag/cl/usebag', src, 3)
end)