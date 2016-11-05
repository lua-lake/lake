local spawn = require 'coro-spawn'

return function(command, verbose)
  local cmd, rest = command:match('(%S+)%s(.+)')
  cmd = cmd or command

  local args = {}
  for arg in (rest or ''):gmatch('%S+') do
    table.insert(args, arg)
  end

  local result = spawn(cmd, { args = args })

  if type(result.pid) == 'string' then
    error('error executing ' .. command .. ': ' .. result.pid, 3)
  end

  local exit_code = result.waitExit()

  if verbose then
    io.write(command .. '\n')
  end

  io.write(result.stderr.read())

  if verbose then
    io.write(result.stdout.read())
  end

  if exit_code ~= 0 then
    error('error executing ' .. command, 3)
  end
end
