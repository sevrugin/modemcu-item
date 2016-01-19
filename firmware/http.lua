local function getRequestData(payload)
    print("Getting Request Data")
      local mimeType = string.match(payload, "Content%-Type: (%S+)\r\n")
      local body_start = payload:find("\r\n\r\n", 1, true)
      local body = payload:sub(body_start, #payload)
      payload = nil
      collectgarbage()
      
      -- print("mimeType = [" .. mimeType .. "]")
      
      if mimeType == "application/json" then
        print("JSON: " .. body)
        status, requestData = pcall(cjson.decode, body)
        if not status then
            requestData = {}
        end
      else
        requestData = {}
      end
      
      return requestData
end

local function parseUri(uri)
   local r = {}
   print('uri: '..uri)
   uri = uri:match('^[/]*(.*)[/]*$')
   --print('uri1: '..uri)
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

-- Parses the client's request. Returns a dictionary containing pretty much everything
-- the server needs to know about the uri.
return function (request)
   --print(request)
   local e = request:find("\r\n", 1, true)
   if not e then return nil end
   local line = request:sub(1, e - 1)
   local r = {}
   _, i, r.method, r.request = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[0-9]+$")
   r.uri = parseUri(r.request)
   r.json = getRequestData(request)
   return r
end