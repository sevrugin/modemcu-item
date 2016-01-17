return {
  ping = function()
    return {name=nodeName, chipid=node.chipid()}
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
