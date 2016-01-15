collectgarbage()
config = dofile("config.lua").read()

nodeName = (config["node-name"])
if nodeName == "" then
    nodeName = "node-"..node.chipid()
end
print('NodeName: '..nodeName)

if config["wifi-ssid"] == "" then
    print("WIFI SOFTAP")
    dofile("wifi.lua").createAP()
else
    print("WIFI STATION")
    dofile("wifi.lua").connect()
end
config = nil

dofile("server.lua")
collectgarbage()
print("Heap:"..node.heap())

