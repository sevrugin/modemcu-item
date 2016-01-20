-- Системные команды ноды. Могут отправляться на группу нод
return {
  ping = function() -- запросить основные данные ноды
    local ip = wifi.sta.getip()
    if ip == nil then
        ip = wifi.ap.getip()
    end
    return {name=nodeName, ip=ip, chipid=node.chipid(), heap=node.heap()}
  end,
  restart = function() -- перезагрузить ноду
    restartAfterDisconnect = true
    return {}
  end,
  heap = function() -- запросить количество оставшейся памяти
    return {value=node.heap()}
  end,
  chipid = function() -- запросить chipid ноды
    return {value=node.chipid()}
  end,
  collectgarbage  = function() -- запуск сборщика мусора
    collectgarbage()
    return {}
  end,
}
