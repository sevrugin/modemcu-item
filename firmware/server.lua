function split(str, delimiter)
    local result = {}
    local i = 1
    local from  = 1
    local delim_from, delim_to = str.find( str, delimiter, from  )
    while delim_from do
        result[i] = str.sub( str, from , delim_from-1 )
        from  = delim_to + 1
        delim_from, delim_to = str.find( str, delimiter, from  )
        i = i+1
    end
    result[i] = str.sub( str, from  )
    return result
end

--Запуск модулей
function run(modulename, command, value)
    local result = {}
    result.success = false
    if file.open(modulename..'.lua') then
        local module = dofile(modulename..'.lua')
        if module[command] ~= nil then
            result.success = true
            result.value = module[command](value)
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
    
    local response = {}

    print(request.module..':'..request.command..':'..request.value)
    local module = split(request.mocule, '/')
    if (module[1] == '*' or module[1] == nodeName) and module[2] == nil then
        if dofile('command-system')[request.command] ~= nil then
            response = run('command-system', request.command, request.value)
        elseif request.module ~= '*' then
            if dofile('command-config')[request.command] ~= nil then
                response = run('command-config', request.command, request.value)
            elseif dofile('command-file')[request.command] ~= nil then
                response = run('command-config', request.command, request.value)
            elseif dofile('command-module')[request.command] ~= nil then
                response = run('command-config', request.command, request.value)
            else
                response.success = false
                response.error = 'Command <'..request.command..'> not exists'
            end
        else
            response.success = false
            response.error = 'Unknown command <'..request.command..'>'
        end
    elseif module[1] == nodeName and module[2] ~= nil then
        if file.open('module-'..module[2]) and dofile('module-'..module[2])[request.command] ~= nil then
            response = run('module-'..module[2], request.command, request.value)
        else
            response.success = false
            response.error = 'Module <'..'module-'..module[2]..'> or command "'..request.command..'" not exists'
        end
    else
        response.success = false
        response.error = 'Unknown module <'..request.module..'>'
    end
    
    connection:send(cjson.encode(response))
    response = nil
    collectgarbage()
end
    
srv = net.createServer(net.TCP)
srv:listen(9898,function(connection)
    connection:on("receive",function(connection, payload)
        payload = cjson.decode(payload)
        onRecieve(connection, payload)
    end)
    connection:on("sent",function(connection) 
        connection:close() 
    end)
end)
