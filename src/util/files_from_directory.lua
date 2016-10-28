local fs = require 'coro-fs'

local function aux(directory, config)
  local files = {}
  for item in fs.scandir(directory) do
    if item.type == 'file' then
      table.insert(files, directory .. '/' .. item.name)
    elseif config.recursive then
      for _, file in ipairs(aux(directory .. '/' .. item.name, config)) do
        table.insert(files, file)
      end
    end
  end
  return files
end

return function(directory, config)
  config = config or {}
  config.match = config.match or ''
  if type(config.match) == 'string' then
    config.match = { config.match }
  end

  local files = {}
  for _, file in ipairs(aux(directory, config)) do
    for _, match in ipairs(config.match) do
      if file:match(match) then
        table.insert(files, file)
        break
      end
    end
  end
  return files
end
