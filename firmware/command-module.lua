-- Работа с модулями ноды
return {
  module_libraries = function() -- список поддерживаемых библиотек 
    result = {}
    local list = file.list()
    for name in pairs(list) do
        tmp = name:match('^lib.([a-z]+).l') -- маска библиотек: lib-{name}.lua/.lc
        if tmp ~= nil then
            table.insert(result, tmp)
        end
    end
    return {value=result}
  end,
  module_list = function() -- список сохраненных модулей
    result = {}
    local list = file.list()
    for name in pairs(list) do
        tmp = name:match('^module.([a-z-]+).json') -- маска настроек для модулей: module-{name}.json
        if tmp ~= nil then
            table.insert(result, tmp)
        end
    end
    return {value=result}
  end,
  module_get = function(name) -- получить конфигурацию модуля
    local data = nil
    filename = 'module-'..name..'.json'
    if (file.open(filename, 'r')) then
        data = file.read()
        file.close()
    else
        return {error='Module not exests'}
    end
    return {value=data}
  end,
  module_create = function(name, data) -- создать модуль с указанием типа библиотеки
    if type(data) ~= 'table' or data.lib == nil or data.title == nil then
        return {error='data: must have "lib" and "title" parameter'}
    end
    -- check module library
    if not file.open('lib-'..data.lib..'.lua', 'r') then
        return {error='Library not exests'}
    end
    file.close()
    
    -- check if config already exists
    local filename = 'module-'..name..'.json'
    if file.open(filename, 'r') then
        file.close()
        return {error='Module already exests'}
    end
    file.open(filename, 'w')
    local config = dofile('lib-'..data.lib..'.lua').config
    config.title = data.title
    
    file.write(cjson.encode(config))
    file.close()
    
    return {message='Module successfuly created'}
  end,
  module_edit = function(name, data) -- сохранить настройку модуля
    -- check if config already exists
    local filename = 'module-'..name..'.json'
    if not file.open(filename, 'r') then
        return {error='Module not exests'}
    end
    config = file.read()
    file.close()
    -- check "data" type
    if type(data) ~= 'table' then
        return {error='data: must be a valid json-data'}
    end
    local status, config = pcall(cjson.decode, config)
    if not status then
        return {error='Can\'t read config file'}
    end
    status = nil

    for k,v in pairs(data) do
        if (config[k]) ~= nil then
            config[k] = (data[k])
        end
    end
    file.open(filename, 'w')
    file.write(cjson.encode(config))
    file.close()
    return {message='Module successfuly saved'}
  end,
  module_remove = function(name) -- удалить модуль
    filename = 'module-'..name..'.json'
    if (file.open(filename, 'r')) then
        data = file.read()
        file.close()
    else
        return {error='Module not exests'}
    end
    file.remove(filename)
    return {message = 'Module succesfully deleted'}
  end
}
