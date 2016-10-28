return function(args)
  local RuleSet = require './src/core/RuleSet'
  local Tree = require './src/core/Tree'
  local TreeBuilder = require './src/core/TreeBuilder'
  local JobQueue = require './src/core/JobQueue'

  local rule_set = RuleSet()
  local job_queue = JobQueue(2)

  if not args[1] then
    print('usage: lake <lakefile> [<target>]')
    return
  end

  local function run(target)
    coroutine.wrap(function()
      local tree = Tree(target, rule_set.rules, rule_set.simple_dependencies)

      if not tree then
        print('error: no recipe for building target "' .. target .. '"')
        return
      end

      if tree.complete then
        print('nothing to be done for target "' .. target .. '"')
      end

      TreeBuilder(job_queue).build(tree)
    end)()
  end

  coroutine.wrap(function()
    setfenv(loadfile(args[1]), setmetatable({
      rule = rule_set.add_rule,
      target = rule_set.add_phony,
      fs = require 'coro-fs',
      exec = require './src/util/exec',
      include = require './src/util/include',
      files_from_directory = require './src/util/files_from_directory',
      map = require './src/util/map',
      set_extension = require './src/util/set_extension',
      add_prefix = require './src/util/add_prefix',
      append = require './src/util/append',
      get_path = function(s)
        local pathjoin = require 'pathjoin'
        local parts = pathjoin.splitPath(s)
        table.remove(parts)
        return pathjoin.pathJoin(table.unpack(parts))
      end
    }, {
      __index = _G
    }))()

    run(args[2] or 'all')
  end)()
end
