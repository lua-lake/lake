return function()
  local rules = {}
  local simple_dependencies = {}

  local function add_rule(phony, targets, deps, builder)
    local empty

    if type(targets) == 'string' then
      targets = { targets }
    end
    if type(deps) == 'string' then
      deps = { deps }
    end
    if not builder then
      builder = function() end
      empty = true
    end

    for _, target in ipairs(targets) do
      local rule = {
        target = target,
        deps = deps,
        builder = builder,
        subscribers = {},
        phony = phony
      }

      if empty then
        rule.empty = true
      end

      if target:match('*') then
        table.insert(rules, rule)
      else
        table.insert(rules, 1, rule)
      end
    end
  end

  local function add_simple_dependency(target, deps)
    simple_dependencies[target] = simple_dependencies[target] or {}
    for _, dep in ipairs(deps) do
      table.insert(simple_dependencies[target], dep)
    end
  end

  return {
    rules = rules,
    simple_dependencies = simple_dependencies,
    add_rule = function(...)
      add_rule(false, ...)
    end,
    add_phony = function(...)
      add_rule(true, ...)
    end,
    add_simple_dependency = add_simple_dependency
  }
end
