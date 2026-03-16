-- Ped locations are kept server-side so clients cannot dump them
local BlackMarket = {
    [1] = {
        ped = 'a_m_m_og_boss_01',
        coords = vector3(-939.8207, -1075.2236, 2.1503),
        heading = 213.8993
    },
    -- Add More
}

function IsPlayerNearBlackMarket(src, maxDist)
    maxDist = maxDist or 5.0
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    for _, data in pairs(BlackMarket) do
        if #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - data.coords) <= maxDist then
            return true
        end
    end
    return false
end

CreateThread(function()
    while true do
        Wait(2000)
        for _, playerId in ipairs(GetPlayers()) do
            local src = tonumber(playerId)
            local playerPed = GetPlayerPed(src)
            local playerCoords = GetEntityCoords(playerPed)

            local nearbyPeds = {}
            for index, data in pairs(BlackMarket) do
                local dist = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - data.coords)
                if dist < 200 then
                    nearbyPeds[index] = { ped = data.ped, coords = data.coords, heading = data.heading }
                end
            end
            TriggerClientEvent('pl_blackmarket:client:syncPeds', src, nearbyPeds)
        end
    end
end)