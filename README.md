# Nodemcu-Item - Модульная IN/OUT система 

### Wi-fi. Конфигурация
При конфигурации по умолчанию (либо при невозможности подключиться к Wi-fi сети) модуль создает SOFTAP точку доступа с именем "{node-name}|node-{chipid()}" и паролем "123456" для переконфигурации. 

IP ноды по умолчанию: "10.0.0.1"

Прием-передача данных осуществляется через mqtt-протокол либо через http-POST запросы на 80 порт в json-формате 
      
      topic: {node-location}{node-name}{command} # home/livingroom/temperature/STATUS
      message:
      {
            "command": "heap|ping|restart", # "ON", "OFF", "GET", "SET", "STATUS", "INFO" - constant
            "value": "{value}",
            "data": "{json}" # custom data
      }

### Общие комманды подписаны на {node-location}+{command} но + проверяется на {node-name} или "all" [command-system.lua]
      ping - Вернуть chip-id и название ноды [success,nodename]
      restart - рестарт ноды
      heap - размер свободной памяти
      chipid - chip-id платы
      collectgarbage - почистить память

### Настройки ноды [command-config.lua] - /home/livingroom/node-1234/node-name
      node-name - сохранить название ноды (уникальный транслит)
      node-description - сохранить описание ноды (любой текст)

### Настройки Wifi [command-config.lua]
      wifi-ssid - установить SSID wi-fi точки
      wifi-password - установить пароль wi-fi точки
      
### Работа с файлами [command-file.lua] - /home/livingroom/node-1234/wifi-ssid
      file-get {filename} - скачать файл
      file-set {filename} - загрузить файл
      file-compile {filename.lua} - скомпилировать файл
      file-list - список файлов

### Настройка модулей [command-module.lua]
      module-list - список всех модулей
      module-types - возвращает все поддерживаемые типы модулей
      module-exists {modulename} - существует ли модуль с таким именем
      module-get {modulename} - возвращает все настройки модуля (json). если модуль не существует возвращает success:false
      module-create {modulename} {moduletype} - создает модуль. если модуль с таким именем существует возвращает success:false
      module-edit {modulename} {module_config} - сохраняет настройки модуля. если модуль не существует возвращает success:false
      module-reload {modulename} - инициализация модуля (например после редактирования конфига)
      module-remove {modulename} - удаляет модуль. если модуль не существует возвращает success:false

### Управление модулями (пр. "home/modulename")
      ON - если модуль поддерживает SET ставит его в max положение
      OFF - если модуль поддерживает SET ставит его в min положение
      GET - если модуль поодерживает GET возвращает текущее значение 
      SET - если модуль поодерживает SET устанавливает текущее значение (число или ON/OFF)
      STATUS - просит модуль заброадкастить свое состояние
      INFO - устанавливается модулем когда он отсылает броадкаст-сообщение о состоянии. такие сообщения анализируются подписками
Если модуль не может выполнить комманду возвращает {success:false}

### Поддерживаемые модули имеют маску [module-{type}.lua]
      # Интерфейс каждого модуля
      bool init(config) - инициализация модуля
      obj get() - получить данные датчика: {value: 25}, {temperature: 26, unit: "C"}
      bool set(value) - установить значение
      bool status() - заказать броадкаст статуса
      
## Файлы конфигураций

### Пример главного конфигурационного файла [config.json]
      {
            "node-name": "home-zal",
            "node-description": "Гостиная",
            "wifi-ssid": "",
            "wifi-password": ""
      }
      
### Примеры конфигураций для модулей
#### [config-dgt-sensor.json]
      # Цифровой сенсор 1/0. Отправляет броадкаст при смене статуса (если delay>0)
      # get - {"result": "succes", "value": 0/1}
      # status - {"module": "home-zal/dgt-sensor", "value": 0/1}
      {
            "description": "Цифрофой сенсор 0/1",
            "module": "dgt-sensor",
            "pin": "1",
            "delay": 0, # Периодичность мониторинга и проверки смены статуса+отправка. 0-никогда
            "onchange": "broadcast" # броадкаст статуса при смене
      }
      
#### [config-analog-sensor.json]
      # Аналоговый сенсор 0-1023. Броадкастит свой статус при delay>0
      # get - {"result": "succes", "value": 0-1023}
      # status - {"module": "home-zal/analog-sensor", "value": 0-1023}
      {
            "description": "Аналоговый сенсор 0-1023",
            "module": "analog-sensor",
            "pin": "0",
            "min": 0,
            "max": 255,
            "mapping-min": 0,
            "mapping-max": 100,
            "unit": "%"
            "delay": 0, # Периодичность мониторинга и проверки смены статуса+отправка. 0-никогда
            "onchange": "broadcast" # броадкаст статуса при смене
      }
      
#### [config-temperature.json]
      # Датчик температуры-влажности dht22 с броадкастом состояния (если delay>0)
      # get - {"result": "succes", "temperature": 10, "humidity": 76, "unit-temperature": "C", "unit-hummidity": "%"}
      # status - {"module": "home-zal/temperature", "temperature": 10, "humidity": 76, "unit-temperature": "C", "unit-hummidity": "%"}
      {
            "description": "Температура в гостиной",
            "module": "dht22",
            "unit-temperature": "C",
            "unit-hummidity": "%"
            "pin": "1",
            "delay": 0 # Частота отправки. 0-никогда
      }
      
#### [config-switch-led.json]
      # get - {"result": "succes", "value": "ON/OFF"}
      # status|set - {"module": "home-zal/switch", "value": "ON/OFF"}
      {
            "description": "Выключатель"
            "module": "switch",
            "pin": "2",
            "min": 0,
            "max": 1023,
            "delay": "0", # Плавность включения,
            "onchange": false # Броадкаст статуса при смене значения
      }
      
#### [config-dimmer-led.json]
      # get - {"result": "succes", "value": "{percent}"}
      # status|set - {"module": "home-zal/dimer", "value": "{percent}"}
      {
            "description": "Диммер"
            "module": "dimmer",
            "pin": "3",
            "min": 0,
            "max": 255,
            "mapping-min": 0,
            "mapping-max": 100,
            "onchange": "broadcast" # Броадкаст статуса при смене значения
      }

## Подписка на события
#### Модуль может быть подписан на броадкаст-события от других модулей
      subscribe-list - список всех подписок
      subscribe-get {name} - конфиг подписки или false
      subscribe-create {name} - создать подписку или false если уже есть
      subscribe-edit {name} {json-data} - залить конфиг подписки или false если нету
      subscribe-remove - удалиьт подписку

#### Конфигурации хранятся в файлах вида [subscribe-{name}.json]
Пример: влючить свет если сработал модуль движения (на выключение нужна отдельная настройка)

      {
            "name": "on_motion_detected", # уникальное название подписки
            "ifmodule": "node-name/motion", # за кем следим
            "op": "=", # =, !=, <, > - условие сверки
            "ifvalue": 1, # значение сверки
            "domodule": "light", # модуль нашей ноды currentnode/light
            "setvalue": "ON" # установить значение
      }
