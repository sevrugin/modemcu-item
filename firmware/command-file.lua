-- Модуль работы с файлами ноды
return {
  file_list = function() -- список файлов
    return {value=file.list()}
  end,
  file_get = function(filename) -- прочитать файл с ноды
    local data = nil
    if file.open(filename) then
        data = file.read()
        file.close()
    else
        return {error='File not exests'}
    end
    return {value=data}
  end,
  file_set = function(filename, data) -- сохранить файл на ноду
    if not file.open(filename, 'w') then
        return {error='Can\'t write file'}
    end
    file.write(data)
    file.close()
    return {}
  end
}
