return {
    createAP = function ()
        print("wifi: create AP")
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
        print("wifi: SSID: "..config["wifi-ssid"])
        print("wifi: PWD: "..config["wifi-password"])
        wifi.sta.config(config["wifi-ssid"], config["wifi-password"], 1)

        local joinCounter = 0
        local joinMaxAttempts = 3
        tmr.alarm(0, 3000, 1, function()
            ip, _, geteway = wifi.sta.getip()
            if ip == nil and joinCounter < joinMaxAttempts then
                print('wifi: connecting to WiFi Access Point ...')
                joinCounter = joinCounter +1
            else
                if joinCounter == joinMaxAttempts then
                    print('wifi: failed to connect to WiFi Access Point.')
                    dofile("wifi.lua").createAP()
                else
                    print('wifi: IP: ', ip)
                    print('wifi: geteway: ', geteway)
                end
                tmr.stop(0)
                joinCounter = nil
                joinMaxAttempts = nil
                collectgarbage()
       end
    end)
    end
}
