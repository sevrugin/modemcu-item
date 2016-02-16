collectgarbage()
config = dofile("config.lua").read()

ip = nil
geteway = nil
nodeName = (config["node-name"])
LOCATION = 'home/'--(config["node-location"])
if nodeName == "" then
    nodeName = "node-"..node.chipid()
end
print('NodeName: '..nodeName)

-- Если не сконфигурирован wifi доступ нода запускается в режиме точки доступа
if config["wifi-ssid"] == "" then
    print("WIFI SOFTAP")
    dofile("wifi.lua").createAP()
else
    print("WIFI STATION")
    dofile("wifi.lua").connect()
end
config = nil

-- Запуск основной части сервера
dofile("server.lua")

collectgarbage()
print("Heap:"..node.heap())

