return {
    asString = function ()
        file.open("config.json", "r")
        local config = file.read()
        file.close()
        return config
    end,
    read = function ()
        file.open("config.json", "r")
        local config = cjson.decode(file.read())
        file.close()
        return config
    end,
    write = function (config)
        file.open("config.json", "w")
        file.write(cjson.encode(config))
        file.close()
    end
}
