# modemcu-item

Модульная IN/OUT система 

# Wi-fi. Конфигурация
При конфигурации по умолчанию (либо при невозможности подключиться к Wi-fi сети) модуль создает SOFTAP точку доступа с именем "Node-item-{node-name|chipId}" и паролем "123456" для переконфигурации. IP ноды: 10.0.0.1

## Общие комманды
      http://{node-ip}/node/heap/

## Настройки ноды
      http://{node-ip}/configure/name/{NODE-NAME}

## Настройки Wifi
      http://{node-ip}/configure/wifi-ssid/{STATION-SSID}
      http://{node-ip}/configure/wifi-password/{STATION-PASSWD}
      
## Работа с конфиг-файлом
