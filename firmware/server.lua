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

function onRecieve(node, module, command, request)
    if node == nil then return false; end
    if module == nil then return false; end
    if command == nil then command = '' end
    if request.value == nil then request.value = '' end
    if request.data == nil then request.data = {} end
    
    local response = {}
    
    print(node..'/'..module..':'..command..':'..request.value)
    local _command = command:gsub("-", "_")
    if (node == '*' or node == nodeName) and module == 'system' then
        if dofile('command-system.lua')[_command] ~= nil then
            response = run('command-system', _command, request.value)
        elseif node ~= '*' then
            if dofile('command-config.lua')[_command] ~= nil then
                response = run('command-config', _command, request.value)
            elseif dofile('command-file.lua')[_command] ~= nil then
                response = run('command-file', _command, request.value, request.data)
            elseif dofile('command-module.lua')[_command] ~= nil then
                response = run('command-module', _command, request.value, request.data)
            else
                response.success = false
                response.error = 'Command <'..command..'> not exists'
            end
        else
            response.success = false
            response.error = 'Unknown command <'..command..'>'
        end
    elseif node == nodeName and module ~= nil then
        if file.open('module-'..module) and dofile('module-'..module)[request.command] ~= nil then
            response = run('module-'..module, _command, request.value)
        else
            response.success = false
            response.error = 'Module <'..'module-'..module..'> or command "'..request.command..'" not exists'
        end
    else
        response.success = false
        response.error = 'Unknown module <'..module..'>'
    end
    
    return response
end

-- запуск http-сервера
srv = net.createServer(net.TCP)
srv:listen(80,function(connection)
    connection:on("receive",function(connection, payload)
       local request = dofile('http.lua')(payload)
       local uri = request.uri
       
       local response = onRecieve(uri.node, uri.module, uri.command, request.json)

       connection:send(cjson.encode(response))
       collectgarbage()
    end)
    connection:on("sent",function(connection) 
        connection:close() 
    end)
    connection:on("disconnection", function(connection) 
        if restartAfterDisconnect then
            node.restart()
        end
    end)
end)

-- запуск mqtt-клиента
_, _, geteway = wifi.sta.getip()
if geteway ~= nil then
	m = mqtt.Client(nodeName, 120, "", "")
	m:lwt("/lwt", "offline", 0, 0)

	m:on("connect", function(connection)
	  print ("connected") 
	end)
	m:on("offline", function(conection) 
	  print ("offline") 
	end)
	m:on("message", function(connection, topic, data) 
	  print(topic .. ":" ) 
	  if data ~= nil then
	    --print(data)
	    static responseTopic = LOCATION..node-name..'/{module}/INFO'
	    m:publish(responseTopic, "hello", 0, 0, function(conn) 
	      print("sent") 
	    end)
	  end
	end)
	m:connect(geteway, 1880, 0, function(conn) 
	  print("connected") 
	end)
	m:subscribe(LOCATION.."#", 0, function(conn) 
	  print("subscribe success") 
	end)
end
