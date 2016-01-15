function onRecieve(connection, request)
    if request.value == nil then
        request.value = ''
    end
    
    local response = {}
    response.success = true
    
    print(request.module..':'..request.command..':'..request.value)
    if request.module == '*' or request.module == nodeName then
        if request.command == 'heap' then
            response.value = node.heap()
        elseif request.command == 'ping' then
            response.heap = node.heap()
            response.chipid = node.chipid()
            response.name = nodeName
        elseif request.command == 'restart' then
            connection:on("disconnection",function(conn) 
                node.restart()
            end)
        elseif request.module ~= '*' then
            if request.command == 'node-name' then
                if request.value ~= '' then
                    nodeName = request.value
                    config = dofile("config.lua").read()
                    config['node-name'] = nodeName
                    dofile("config.lua").write(config)
                    config = nil
                end
                response.value = nodeName
            end
        else
            response.success = false
            response.error = 'Unknown command <'..request.command..'>'
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
