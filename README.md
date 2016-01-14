# Nodemcu-Item - Модульная IN/OUT система 

### Wi-fi. Конфигурация
При конфигурации по умолчанию (либо при невозможности подключиться к Wi-fi сети) модуль создает SOFTAP точку доступа с именем "Node-item-{node-name|chipId}" и паролем "123456" для переконфигурации. IP ноды: "10.0.0.1"

Прием-передача данных осуществляется через UDP-сокет на порту 9898 в json-формате
      
      {
            "module": "*|home-zal|kitchen", # "home-zal/temperature", "kitchen/top-light"
            "command": "heap|ping|restart", # "ON", "OFF", "GET", "SET", "STATUS" - constant
            "value": "{value}",
            # custom data
      }

### Общие комманды (могут быть броадкаст)
      ping - Вернуть chip-id и название ноды [success,nodename]
      restart - рестарт ноды
      heap - размер свободной памяти
      chipid - chip-id платы
      collectgarbage - почистить память

### Настройки ноды
      node-name - запросить или сохранить название ноды (уникальный транслит)
      node-description - запросить или сохранить описание ноды (любой текст)

### Настройки Wifi
      wifi-ssid - запросить или установить SSID wi-fi точки
      wifi-password - запросить или установить пароль wi-fi точки
      
### Работа с файлами
      file-get {filename} - скачать файл
      file-set {filename} - загрузить файл
      file-compile {filename.lua} - скомпилировать файл
      file-list - список файлов

## Пример полного конфиг-файла config.json
      {
            "name": "home-zal",
            "description": "Гостиная",
            "modules": {
                  # Цифровой сенсор 1/0. Отправляет броадкаст при смене статуса (если delay>0)
                  # get - {"result": "succes", "value": 0/1}
                  # status - {"module": "home-zal/dgt-sensor", "value": 0/1}
                  "dgt-sensor":{
                        "description": "Цифрофой сенсор 0/1",
                        "module": "dgt-sensor",
                        "pin": "1",
                        "delay": 0, # Периодичность мониторинга и проверки смены статуса+отправка. 0-никогда
                  },
                  # Аналоговый сенсор 0-1023. Броадкастит свой статус при delay>0
                  # get - {"result": "succes", "value": 0-1023}
                  # status - {"module": "home-zal/analog-sensor", "value": 0-1023}
                  "analod-sensor":{
                        "description": "Аналоговый сенсор 0-1023",
                        "module": "analog-sensor",
                        "pin": "0",
                        "delay": 0, # Периодичность мониторинга и проверки смены статуса+отправка. 0-никогда
                  },
                  # Датчик температуры-влажности dht22 с броадкастом состояния (если delay>0)
                  # get - {"result": "succes", "temperature": 10, "humidity": 76}
                  # status - {"module": "home-zal/temperature", "temperature": 10, "humidity": 76}
                  "temperature":{
                        "description": "Температура в гостиной",
                        "module": "dht22",
                        "pin": "1",
                        "delay": 0 # Частота отправки. 0-никогда
                  },
                  # get - {"result": "succes", "value": "ON/OFF"}
                  # status|set - {"module": "home-zal/switch", "value": "ON/OFF"}
                  "switch-led":{
                        "description": "Выключатель"
                        "module": "switch",
                        "pin": "2",
                        "delay": "0", # Плавность включения,
                        "broadcast-on-set": 0 # Броадкаст статуса при смене значения
                  },
                  # get - {"result": "succes", "value": "{percent}"}
                  # status|set - {"module": "home-zal/switch", "value": "{percent}"}
                  "dimmer-led":{
                        "description": "Диммер"
                        "module": "dimmer",
                        "pin": "3",
                        "min": 0,
                        "max": 255,
                        "broadcast-on-set": 0 # Броадкаст статуса при смене значения
                  }
            }
      }
