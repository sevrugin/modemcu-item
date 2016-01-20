-- Модуль настройки основных параметров ноды
return {
  node_location = function(value) -- расположение ноды
    if (value ~= '') then
        LOCATION = value
        local config = dofile("config.lua").read()
        config['node-location'] = LOCATION
        dofile("config.lua").write(config)
        config = nil
    end
    return {value=LOCATION}
  end,
  node_name = function(value) -- название ноды
    if (value ~= '') then
        nodeName = value
        local config = dofile("config.lua").read()
        config['node-name'] = nodeName
        dofile("config.lua").write(config)
        config = nil
    end
    return {value=nodeName}
  end,
  node_description = function(value) -- строка описания ноды
    local config = dofile("config.lua").read()
    if (value ~= '') then
        config['node-description'] = value
        dofile("config.lua").write(config)
    end
    value = (config['node-description'])
    config = nil
    return {value=value}
  end,
  wifi_ssid = function(value) -- ssid wifi-сети
    local config = dofile("config.lua").read()
    if (value ~= '') then
        config['wifi-ssid'] = value
        dofile("config.lua").write(config)
    end
    value = (config['wifi-ssid'])
    config = nil
    return {value=value}
  end,
  wifi_password = function(value) -- пароль от wifi сети
    local config = dofile("config.lua").read()
    if (value ~= '') then
        config['wifi-password'] = value
        dofile("config.lua").write(config)
    end
    value = (config['wifi-password'])
    config = nil
    return {value=value}
  end
}
