return function()
  local rules = {}
  local indirect_dependencies = {}

  local function add_rule(phony, targets, deps, builder)
    if type(targets) == 'string' then
      targets = { targets }
    end
    if type(deps) == 'string' then
      deps = { deps }
    end
    builder = builder or function() end

    for _, target in ipairs(targets) do
      local rule = {
        target = target,
        deps = deps,
        builder = builder,
        subscribers = {},
        phony = phony
      }

      if target:match('*') then
        table.insert(rules, rule)
      else
        table.insert(rules, 1, rule)
      end
    end
  end

  local function add_indirect_dependency(target, deps)
    indirect_dependencies[target] = indirect_dependencies[target] or {}
    for _, dep in ipairs(deps) do
      table.insert(indirect_dependencies[target], dep)
    end
  end

  return {
    rules = rules,
    indirect_dependencies = indirect_dependencies,
    add_rule = function(...)
      add_rule(false, ...)
    end,
    add_phony = function(...)
      add_rule(true, ...)
    end,
    add_indirect_dependency = add_indirect_dependency
  }
end
