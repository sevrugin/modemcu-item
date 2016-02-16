restartAfterDisconnect = false

-- парсинг строки запроса на состовляющие /{LOCATION}/{node-name}/{command}
local function parseUri(uri)
   local r = {}
   uri = uri:match('^[/]*(.*)[/]*$')
   --print('uri: '..uri)
   local pattern = "^"..LOCATION.."([^/]+)[/]*([^/]*)[/]*([^/]*)$"
   --print('pattern: '..pattern)
   local node, module, command = uri:match(pattern)
   --print('nodename: '..nodename)
   --print('command: '..command)
   r.node = node
   r.module = module
   r.command = command
   
   return r
end

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

function onRecieve(node, module, command, request, isAdmin)
    if isAdmin == nil then isAdmin = false; end
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
        elseif node ~= '*' and isAdmin then -- Only admin can run this commands via http
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
       
       local response = onRecieve(uri.node, uri.module, uri.command, request.json, true)

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

m = mqtt.Client(nodeName, 120, "", "")
m:lwt("/lwt", "offline", 0, 0)

m:on("connect", function(connection)
  
end)
m:on("offline", function(conection) 
  print ("mqtt: offline") 
end)
m:on("message", function(connection, topic, data) 
    local uri = parseUri(topic)
    if uri.command == "STATUS" then -- some module send own STATUS
        -- todo: send to Roles
        return
    end
    print("mqtt: message to "..topic) 
    --local status, json = pcall(cjson.decode, data)
    --if not status then
        json = {}
    --end
    local response = onRecieve(uri.node, uri.module, uri.command, json, false)
    
    collectgarbage()
    if restartAfterDisconnect then
        node.restart()
    end
    
    if response.success then
        response.success = nil
        local responseTopic = LOCATION..nodeName..'/'..uri.module..'/STATUS'
        if uri.module == "system" then -- All system module can return answer
            response.command = uri.command
        elseif uri.command == "INFO" then -- Somebody need module status
        else -- No need response
            response = nil
        end
        if response ~= nil then
            print("mqtt: sent to topic: "..responseTopic)
            m:publish(responseTopic, cjson.encode(response), 0, 0, function(conn) 
                print("mqtt: sent") 
            end)
        end
    else
        print("mqtt: error - "..response.error)
    end
end)
-- запуск mqtt-клиента
tmr.alarm(1, 5000, 1, function()
    if geteway ~= nil then
        print("mqtt: try to connect")
    	m:connect(geteway, 1883, 0, function ()
          print ("mqtt: connected") 
          tmr.stop(1)
          print("mqtt: subscribe to "..LOCATION.."#")
          m:subscribe(LOCATION.."#", 0, function(conn) 
            print("mqtt: subscribe success") 
          end)
    	end)
    else
        print('mqtt: gateway is nil')
    end
end)
