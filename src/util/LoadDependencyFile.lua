local fs = require 'coro-fs'

return function(rule_set)
  return function(filename)
    local contents = (fs.readFile(filename) or ''):gsub('\\\n', ' ')
    for target, dependency_list in contents:gmatch('([^\n]+):([^\n]+)') do
      local dependencies = {}
      for dependency in dependency_list:gmatch('%S+') do
        table.insert(dependencies, dependency)
      end
      rule_set.add_simple_dependency(target, dependencies)
    end
  end
end
