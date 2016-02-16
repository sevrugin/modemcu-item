-- собирает таблицу параметров на основе POST-данных
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
      local status, requestData = pcall(cjson.decode, body)
      if not status then
          requestData = {}
      end
    else
      requestData = {}
    end
      
    return requestData
end

-- Преобразует заголовок http-запроса в набор параметров
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
