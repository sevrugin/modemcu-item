return {
  file_list = function()
    return {value=file.list()}
  end,
  file_get = function(filename)
    local data = nil
    if file.open(filename) then
        data = file.read()
        file.close()
    else
        return {error='File not exests'}
    end
    return {value=data}
  end,
  file_set = function(filename, data)
    if not file.open(filename) then
        return {error='File not exests'}
    end
    file.write(data)
    file.close()
    return {}
  end
}
