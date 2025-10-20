
function GetFramework()
    if Config.Framework ~= 'autodetect' then
        return Config.Framework
    end

    if GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    else
        print('^1[Warning] No compatible Framework detected.^0')
        return nil
    end
end