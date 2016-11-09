local function locals()
  local locals = {}
  local i = 1
  while true do
    local k, v = debug.getlocal(3, i)
    if k then
      locals[k] = v
    else
      break
    end
    i = 1 + i
  end
  return locals
end

return function(file, environment)
  if file:match('^./') then
    local current_directory = debug.getinfo(2, 'S').source:sub(2):match('(.*/)') or ''
    file = current_directory .. file:match('^./(.+)')
  end
  if environment then
    return setfenv(loadfile(file), setmetatable({}, {
      __index = environment
    }))()
  else
    return setfenv(loadfile(file), setmetatable(locals(), {
      __index = getfenv(2)
    }))()
  end
end
