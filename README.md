# Nodemcu-Item - Модульная IN/OUT система 

## Wi-fi. Конфигурация
При конфигурации по умолчанию (либо при невозможности подключиться к Wi-fi сети) модуль создает SOFTAP точку доступа с именем "Node-item-{node-name|chipId}" и паролем "123456" для переконфигурации. IP ноды: "10.0.0.1"

Прием-передача данных осуществляется через UDP-сокет на порту 9898 в json-формате
      {
            "module": "all/node", # "zal/temperature", "kitchen/top-light"
            "command": "heap", # "ON", "OFF", "GET", "SET" - constant
            "value": "{value}",
            # custom data
      }

## Общие комманды
      node/ping - броадкаст пинг всех нод. Вернуть название ноды [success,nodename]
      node/restart - рестарт ноды
      node/heap - размер свободной памяти
      node/chipid - chip-id платы

## Настройки ноды
      configure/name/{NODE-NAME} - запросить или сохранить название ноды (уникальный транслит)
      configure/description/{NODE-DESCRIPTION} - запросить или сохранить описание ноды (любой текст)

## Настройки Wifi
      configure/wifi-ssid/{STATION-SSID} - запросить или установить SSID wi-fi точки
      configure/wifi-password/{STATION-PASSWD} - запросить или установить пароль wi-fi точки
      
## Работа с файлами
      file/get/config.json - скачать файл
      file/set/config.json/{data} - загрузить файл

# Ответы любого модуля всегда отдаются в json-формате
      {
            "result": "success/fail",
            "message": "result message",
            "json": "json-данные если необходимо"
      }

# Пример полного конфик-файла config.json
      {
            "name": "home-zal",
            "description": "Гостиная",
            "modules": {
                  # get - {"result": "succes", "temperature": 10, "humidity": 76}
                  # status - {"module": "home-zal/temperature", "temperature": 10, "humidity": 76}
                  "temperature":{
                        "description": "Температура в гостиной",
                        "module": "dht22",
                        "pin": "1",
                        "delay": 0 # Частота отправки. 0-никогда
                  },
                  # get - {"result": "succes", "value": "ON/OFF"}
                  # status - {"module": "home-zal/switch", "value": "ON/OFF"}
                  "switch":{
                        "description": "Выключатель"
                        "module": "switch",
                        "pin": "2"
                  }
            }
      }
