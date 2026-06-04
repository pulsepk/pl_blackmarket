
local spawnedPeds = {}

-- ── NUI callbacks ─────────────────────────────────────────────────────────────

RegisterNUICallback('buyItems', function(data, cb)
    local cart  = data.cart
    local total = data.total

    -- Check funds via server callback for UX feedback before triggering purchase.
    -- The server re-validates independently — this is not the security gate.
    lib.callback('pl_blackmarket:checkPlayerFunds', false, function(canAfford)
        if not canAfford then
            exports.pl_lib:Notify('Black Market', 'You do not have enough money to make this purchase.', 'error')
            cb({ status = 'error' })
            return
        end
        TriggerServerEvent('pl_blackmarket:server:purchaseItems', cart)
        cb({ status = 'ok' })
    end, total)
end)

RegisterNUICallback('hideFrame', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

-- ── Market UI ─────────────────────────────────────────────────────────────────

function OpenBlackMarket()
    Config.DebugPrint("Requesting Black Market UI from server")
    TriggerServerEvent("pl_blackmarket:OpenUI")
end

RegisterNetEvent("pl_blackmarket:client:open", function(products)
    SendNUIMessage({ action = 'showUI', products = products })
    SetNuiFocus(true, true)
end)

-- Server-side notification relay (e.g. blacklisted-job denial)
RegisterNetEvent('pl_blackmarket:client:notify', function(data)
    exports.pl_lib:Notify(data.title, data.description, data.type)
end)

-- ── Target interaction ────────────────────────────────────────────────────────

-- Fired by pl_lib when the player selects any AddEntityTarget option.
AddEventHandler('pl_lib:targetSelected', function(name)
    if name == 'BlackMarketPed' then
        OpenBlackMarket()
    end
end)

-- ── Ped management ────────────────────────────────────────────────────────────

function StartPoint(data, index)
    RequestModel(data.ped)
    while not HasModelLoaded(data.ped) do Wait(0) end

    local ped = CreatePed(0, data.ped, data.coords.x, data.coords.y, data.coords.z - 1, data.heading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    spawnedPeds[index] = ped
    Config.DebugPrint(("Spawned blackmarket ped [%s] model '%s'"):format(index, data.ped))

    if Config.Interaction ~= 'textui' then
        -- 'target' mode: pl_lib auto-detects ox_target or qb-target.
        exports.pl_lib:AddEntityTarget(ped, {
            name     = 'BlackMarketPed',
            label    = 'Black Market Dealer',
            icon     = 'fas fa-mask',
            distance = 1.5,
        })
    else
        CreateThread(function()
            local shown = false
            while DoesEntityExist(ped) do
                local dist = #(GetEntityCoords(PlayerPedId()) - data.coords)

                if dist < 1.0 then
                    if not shown then
                        exports.pl_lib:TextUIShow('[E] Black Market Dealer', {
                            position = 'right-center',
                            icon     = 'fas fa-mask',
                            style    = {
                                borderRadius    = 6,
                                backgroundColor = '#1a1a1a',
                                color           = '#ff4b2b',
                                fontSize        = 18
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
                        exports.pl_lib:TextUIHide()
                        shown = false
                    end
                end

                Wait(0)
            end
            if shown then exports.pl_lib:TextUIHide() end
        end)
    end
end

RegisterNetEvent('pl_blackmarket:client:syncPeds', function(nearbyPeds)
    for index, ped in pairs(spawnedPeds) do
        if not nearbyPeds[index] then
            if DoesEntityExist(ped) then DeletePed(ped) end
            spawnedPeds[index] = nil
            Config.DebugPrint(("Despawned blackmarket ped [%s]"):format(index))
        end
    end

    for index, pedData in pairs(nearbyPeds) do
        if not spawnedPeds[index] then
            StartPoint(pedData, index)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() ~= name then return end
    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)
