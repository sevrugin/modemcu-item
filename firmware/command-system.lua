return {
  ping = function()
    local ip = wifi.sta.getip()
    if ip == nil then
        ip = wifi.ap.getip()
    end
    return {name=nodeName, ip=ip, chipid=node.chipid(), heap=node.heap()}
  end,
  restart = function()
    restartAfterDisconnect = true
    return {}
  end,
  heap = function()
    return {value=node.heap()}
  end,
  chipid = function()
    return {value=node.chipid()}
  end,
  collectgarbage  = function()
    collectgarbage()
    return {}
  end,
}
