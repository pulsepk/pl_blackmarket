RegisterNetEvent('blackmarket:client:openShop', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        categories = Config.Categories
    })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('purchaseItem', function(data, cb)
    TriggerServerEvent('blackmarket:server:purchaseItem', data)
    cb({})
end)

function SendReactMessage(action, data)
    SendNUIMessage({
      action = action,
      data = data
    })
end

local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end
RegisterNUICallback('hideFrame', function(data, cb)
    toggleNuiFrame(false)
end)

RegisterCommand("blackmarket", function()
    SendNUIMessage({
        action = 'showUI',
        products = data
    })
    SetNuiFocus(true, true)
    --TriggerEvent('blackmarket:client:openShop')
end)
