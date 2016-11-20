return function(args)
  local RuleSet = require './src/core/RuleSet'
  local Tree = require './src/core/Tree'
  local TreeBuilder = require './src/core/TreeBuilder'
  local JobQueue = require './src/core/JobQueue'

  local option_parser = require './src/core/options'
  local options = option_parser(args)

  if not options then
    print(option_parser.usage)
    return
  end

  local rule_set = RuleSet()
  local job_queue = JobQueue(options.job_count)

  local function run(target, on_complete)
    local tree = Tree(target, rule_set.rules, rule_set.simple_dependencies)

    if not tree then
      print('error: no recipe for building target "' .. target .. '"')
      return
    end

    if tree.complete then
      print('nothing to be done for target "' .. target .. '"')
    end

    TreeBuilder(job_queue).build(tree, on_complete)
  end

  local lakefile = loadfile(options.lakefile)

  if not lakefile then
    print(options.lakefile .. ' not found')
    return
  end

  local exec = require './src/util/exec'
  local include = require './src/util/include'

  local environment
  environment = setmetatable({
    config = options.config,
    rule = rule_set.add_rule,
    target = rule_set.add_phony,
    fs = require 'coro-fs',
    exec = exec,
    vexec = function(command) exec(command, true) end,
    include = include,
    import = function(file) return include(file, environment) end,
    files_from_directory = require './src/util/files_from_directory',
    map = require './src/util/map',
    set_extension = require './src/util/set_extension',
    add_prefix = require './src/util/add_prefix',
    append = require './src/util/append',
    flatten = require './src/util/flatten',
    flat_map = require './src/util/flat_map',
    load_dependency_file = require './src/util/LoadDependencyFile'(rule_set),
    path = require 'path',
    env = require 'env'
  }, {
    __index = _G
  })

  coroutine.wrap(function()
    setfenv(lakefile, environment)()

    local function run_next()
      if #options.targets > 0 then
        local target = table.remove(options.targets, 1)
        run(target, run_next)
      end
    end

    run_next()
  end)()
end
