local zones = {}

local function BagAnim()
    local dict = "anim@heists@money_grab@briefcase"
    lib.requestAnimDict(dict)
    TaskPlayAnim(cache.ped, dict, "put_down_case", 8.0, -8.0, -1, 1, 0, false, false, false)
    Wait(1000)
    ClearPedTasks(cache.ped)
    RemoveAnimDict(dict)
end

RegisterNetEvent("qb-clothingbag/cl/usebag", function(uses)
    print(uses)
    local coords = GetEntityCoords(cache.ped)
    local forward = GetEntityForwardVector(cache.ped)
    local x, y, z = table.unpack(coords + forward * 0.5)

    BagAnim()
    local obj, netid = lib.callback.await('qb-clothingbag/cb/spawnobject', false, Config.model, vector3(x, y, z - 1))
    TriggerServerEvent('qb-clothingbag/sv/addinteracrt', netid, uses)
end)

RegisterNetEvent("qb-clothingbag/cl/addinteracrt", function(netid, uses)
    local entity = NetworkGetEntityFromNetworkId(netid)
    local coords = GetEntityCoords(entity)

    if Config.TargetType == "interact" then
        exports.interact:AddEntityInteraction({
            netId = netid,
            id = 'clothingbag_' .. netid, -- needed for removing interactions
            distance = 5.0, -- optional
            interactDst = 2.0, -- optional
            ignoreLos = true, -- optional ignores line of sight

            options = {
                {
                    label = 'Open Bag',
                    action = function()
                        if DoesEntityExist(entity) then
                            TriggerEvent("qb-clothing:client:openOutfitMenu")
                        end
                    end
                },
                {
                    label = 'Take Bag',
                    action = function()
                        if DoesEntityExist(entity) then
                            FreezeEntityPosition(cache.ped, true)
                            lib.requestAnimDict("pickup_object")
                            TaskPlayAnim(cache.ped, "pickup_object", "pickup_low", -8.0, 8.0, -1, 49, 1.0)
                            RemoveAnimDict("pickup_object")
        
                            Wait(1000)
                            exports.interact:RemoveEntityInteraction(netid, 'clothingbag_' .. netid)
                            TriggerServerEvent("qb-clothingbag/sv/takebag", netid, uses)
                            FreezeEntityPosition(cache.ped, false)
                            ClearPedTasks(cache.ped)
                        end
                    end
                }
            }
        })
    elseif Config.TargetType == "target" then
        exports['qb-target']:AddTargetEntity(entity, {
            options = {
                {
                    label = 'Open Bag',
                    icon = 'fas fa-tshirt',
                    action = function(data)
                        if DoesEntityExist(entity) then
                            TriggerEvent("qb-clothing:client:openOutfitMenu")
                        end
                    end
                },
                {
                    label = 'Take Bag',
                    icon = 'fas fa-shopping-bag',
                    action = function()
                        if DoesEntityExist(entity) then
                            FreezeEntityPosition(cache.ped, true)
                            lib.requestAnimDict("pickup_object")
                            TaskPlayAnim(cache.ped, "pickup_object", "pickup_low", -8.0, 8.0, -1, 49, 1.0)
                            RemoveAnimDict("pickup_object")
        
                            Wait(1000)
                            
                            exports['qb-target']:RemoveTargetEntity(entity)
                            TriggerServerEvent("qb-clothingbag/sv/takebag", netid, uses)
                            FreezeEntityPosition(cache.ped, false)
                            ClearPedTasks(cache.ped)
                        end
                    end
                }
            },
            distance = 2.0
        })
    end
end)