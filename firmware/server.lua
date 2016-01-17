restartAfterDisconnect = false

--Запуск модулей
function run(modulename, command, value, data)
    local result = {}
    result.success = false
    if file.open(modulename..'.lua') then
        local module = dofile(modulename..'.lua')
        if module[command] ~= nil then
            result = module[command](value, data)
            if result.error == nil then
                result.success = true
            else
                result.success = false
            end
        else
            result.error = 'Command "'..modulename..':'..command..'" not exists'
        end
        module = nil
    else
        result.error = 'Module "'..modulename..'" not exists'
    end
    collectgarbage()
    return result
end

function onRecieve(connection, request)
    if request.module == nil then request.module = '' end
    if request.command == nil then request.command = '' end
    if request.value == nil then request.value = '' end
    if request.data == nil then request.data = {} end
    
    local response = {}
    
    print(request.module..':'..request.command..':'..request.value)
    local command = request.command:gsub("-", "_")
    local node, module = request.module:match("([^/]+)[/]*([^/]*)")
    if (node == '*' or node == nodeName) and module == '' then
        if dofile('command-system.lua')[command] ~= nil then
            response = run('command-system', command, request.value)
        elseif node ~= '*' then
            if dofile('command-config.lua')[command] ~= nil then
                response = run('command-config', command, request.value)
            elseif dofile('command-file.lua')[command] ~= nil then
                response = run('command-file', command, request.value, request.data)
            elseif dofile('command-module.lua')[command] ~= nil then
                response = run('command-module', command, request.value, request.data)
            else
                response.success = false
                response.error = 'Command <'..request.command..'> not exists'
            end
        else
            response.success = false
            response.error = 'Unknown command <'..request.command..'>'
        end
    elseif node == nodeName and module ~= nil then
        if file.open('module-'..module) and dofile('module-'..module)[request.command] ~= nil then
            response = run('module-'..module, command, request.value)
        else
            response.success = false
            response.error = 'Module <'..'module-'..module..'> or command "'..request.command..'" not exists'
        end
    else
        response.success = false
        response.error = 'Unknown module <'..request.module..'>'
    end
    node = nil
    module = nil
    connection:send(cjson.encode(response))
    response = nil
    collectgarbage()
end
    
srv = net.createServer(net.TCP)
srv:listen(9898,function(connection)
    connection:on("receive",function(connection, payload)
        local status, result = pcall(cjson.decode, payload)
        if not status or type(result) ~= 'table' then
            response = {}
            response.success = false;
            response.error = 'Can\'t parse request json'
            connection:send(cjson.encode(response))
            response = nil
            collectgarbage()
        else
            onRecieve(connection, result)
        end
        status = nil
    end)
    connection:on("sent",function(connection) 
        connection:close() 
    end)
    connection:on("disconnection",function(connection) 
        if restartAfterDisconnect then
            node.restart()
        end
    end)
end)
