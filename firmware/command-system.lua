return {
  local ping = function()
    return {name=nodeName, chipid=node.chipid()}
  end
}
