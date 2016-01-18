return {
  config = {
    title = '', -- тектовое описание
    lib = 'switch', -- используемая библиотека
    pin = nil, -- пин управления
    min = 0,
    max = 1023,
    delay = 0, -- Плавность включения
    onchange = false -- Броадкаст статуса при смене значения
  },
  init = function(config)
    local module = {
        status = gpio.LOW,
        config = config
    }
    function module:get()
        return self.status
    end
    function module:set(value)
        if value == 'ON' then
          value = self.config.max
        elseif value == 'OFF' then
          value = self.config.min
        end
        -- onchange
        if self.status ~= value then
          self.status()
        end
        self.status = value
        if self.config.pin ~= nil then
          gpio.write(self.config.pin, value)
        end
    end
    function module:status()
      --broadcast self.status
    end

    if module.config.pin ~= nil then
      gpio.mode(config.pin, gpio.OUTPUT)
      module.set(gpio.LOW)
    end
    
    return module
  end,
}
