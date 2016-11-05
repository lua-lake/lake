return function(args)
  local RuleSet = require './src/core/RuleSet'
  local Tree = require './src/core/Tree'
  local TreeBuilder = require './src/core/TreeBuilder'
  local JobQueue = require './src/core/JobQueue'

  local options = require './src/core/options'(args)

  if not options then
    print(options.usage)
    return
  end

  local rule_set = RuleSet()
  local job_queue = JobQueue(options.job_count)

  local function run(target)
    coroutine.wrap(function()
      local tree = Tree(target, rule_set.rules, rule_set.indirect_dependencies)

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

  local lakefile = loadfile(options.lakefile)

  if not lakefile then
    print(options.lakefile .. ' not found')
    return
  end

  coroutine.wrap(function()
    setfenv(lakefile, setmetatable({
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
      flatten = require './src/util/flatten',
      flat_map = require './src/util/flat_map',
      load_dependency_file = require './src/util/LoadDependencyFile'(rule_set),
      path = require 'path'
    }, {
      __index = _G
    }))()

    run(options.target)
  end)()
end
