
local spawnedPeds = {}

RegisterNUICallback('buyItems', function(data, cb)
    local src = source
    local cart = data.cart
    local total = data.total

    lib.callback('pl_blackmarket:checkPlayerFunds', src, function(canAfford)
        if not canAfford then
            cb({ status = 'error' })
            lib.notify({
                title = 'Black Market',
                description = 'You do not have enough money to make this purchase.',
                type = 'error'
            })

            return
        end
        TriggerServerEvent('pl_blackmarket:server:purchaseItems', cart)
        cb({ status = 'ok' })
    end, total)
end)

RegisterNUICallback('hideFrame', function(data, cb)
    SetNuiFocus(false, false)
end)

function OpenBlackMarket()
    Config.DebugPrint("Requesting Black Market UI from server")
    TriggerServerEvent("pl_blackmarket:OpenUI")
end
RegisterNetEvent("pl_blackmarket:client:open", function(products)
    SendNUIMessage({
        action = 'showUI',
        products = products
    })
    SetNuiFocus(true, true)
end)

function StartPoint(data, index)
    RequestModel(data.ped)
    while not HasModelLoaded(data.ped) do Wait(0) end

    local ped = CreatePed(0, data.ped, data.coords.x, data.coords.y, data.coords.z - 1, data.heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    spawnedPeds[index] = ped
    Config.DebugPrint(("Spawned blackmarket ped [%s] model '%s'"):format(index, data.ped))

    if Config.Interaction == 'ox-target' then
        exports.ox_target:addLocalEntity(ped, {
            name = 'BlackMarketPed',
            label = 'Black Market Dealer',
            icon = 'fas fa-mask',
            onSelect = function ()
                OpenBlackMarket()
            end,
            distance = 1.5
        })
    elseif Config.Interaction == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, { 
            options = {
                {
                    icon = 'fas fa-mask',
                    label = 'Black Market Dealer',
                    action = function()
                        OpenBlackMarket()
                    end,
                },
            }, 
            distance = 1.5, 
        })
    elseif Config.Interaction == 'textui' then
        CreateThread(function()
            local shown = false
            while DoesEntityExist(ped) do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local dist = #(playerCoords - data.coords)

                if dist < 1.0 then
                    if not shown then
                        lib.showTextUI('[E] Black Market Dealer', {
                            position = 'right-center',
                            icon = 'fas fa-mask',
                            style = {
                                borderRadius = 6,
                                backgroundColor = '#1a1a1a',
                                color = '#ff4b2b',
                                fontSize = 18
                            }
                        })
                        shown = true
                    end
                    if IsControlJustReleased(0, 38) then
                        OpenBlackMarket()
                        Wait(1000)
                    end
                else
                    if shown then
                        lib.hideTextUI()
                        shown = false
                    end
                end

                Wait(0)
            end
            if shown then lib.hideTextUI() end
        end)
    end
end

RegisterNetEvent('pl_blackmarket:client:syncPeds', function(nearbyPeds)
    for index, ped in pairs(spawnedPeds) do
        if not nearbyPeds[index] then
            if DoesEntityExist(ped) then
                DeletePed(ped)
            end
            spawnedPeds[index] = nil
            Config.DebugPrint(("Despawned blackmarket ped [%s]"):format(index))
        end
    end

    for index, data in pairs(nearbyPeds) do
        if not spawnedPeds[index] then
            StartPoint(data, index)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for index, ped in pairs(spawnedPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
end)
