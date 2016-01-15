return {
    createAP = function ()
        local config = dofile("config.lua").read()
        wifi.setmode(wifi.SOFTAP)

        print("Wi-fi AP: "..nodeName)
        print("Wi-fi pwd: 12345678")

        local apConfig = {}
        apConfig.ssid = (name)
        apConfig.pwd="12345678"
        wifi.ap.config(apConfig)

        local ipConfig = {}
        ipConfig.ip = "10.0.0.1"
        ipConfig.netmask = "255.255.255.0"
        ipConfig.gateway = "10.0.0.1"
    
        wifi.ap.setip(ipConfig)
    
        apConfig = nil
        ipConfig = nil
        collectgarbage()
    end,
    connect = function()
        local config = dofile("config.lua").read()
        
        wifi.setmode(wifi.STATION)
        print("SSID:"..config["wifi-ssid"])
        print("PWD:"..config["wifi-password"])
        wifi.sta.config(config["wifi-ssid"], config["wifi-password"], 1)

        local joinCounter = 0
        local joinMaxAttempts = 3
        tmr.alarm(0, 3000, 1, function()
            local ip = wifi.sta.getip()
            if ip == nil and joinCounter < joinMaxAttempts then
                print('Connecting to WiFi Access Point ...')
                joinCounter = joinCounter +1
            else
                if joinCounter == joinMaxAttempts then
                    print('Failed to connect to WiFi Access Point.')
                    
                    dofile("wifi.lua").createAP()
                else
                    print('IP: ',ip)
                end
                tmr.stop(0)
                joinCounter = nil
                joinMaxAttempts = nil
                collectgarbage()
       end
    end)
    end
}