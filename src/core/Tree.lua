local fs = require 'coro-fs'

local function exists(target)
  return fs.stat(target) ~= nil
end

local function is_directory(target)
  return fs.stat(target).type == 'directory'
end

local function mtime(target)
  local stat = fs.stat(target)
  if stat then return stat.mtime end
end

local function is_before(mtime1, mtime2)
  if mtime1.sec == mtime2.sec then
    return mtime1.nsec < mtime2.nsec
  else
    return mtime1.sec < mtime2.sec
  end
end

return function(target, rules, simple_dependencies)
  local tree_cache = {}

  local function make_tree(target)
    if tree_cache[target] then return tree_cache[target] end

    local target_exists = exists(target)
    local target_mtime = mtime(target)

    for _, rule in ipairs(rules) do
      local match = target:match('^' .. rule.target:gsub('*', '(%%S+)') .. '$')
      local out_of_date = false

      if match ~= nil then
        local satisfied_all_deps = true
        local all_deps_complete = true
        local tree = {
          rule = rule,
          target = target,
          deps = {},
          match = match
        }

        if target_exists then
          for _, simple_dependency in ipairs(simple_dependencies[target] or {}) do
            if not exists(simple_dependency) or is_before(target_mtime, mtime(simple_dependency)) then
              out_of_date = true
            end
          end
        end

        for _, dep in ipairs(rule.deps) do
          local dep = dep:gsub('*', match)
          local sub_tree = make_tree(dep)
          if not sub_tree then
            satisfied_all_deps = false
            break
          elseif not sub_tree.complete then
            out_of_date = true
            all_deps_complete = false
            if sub_tree.deps then
              table.insert(tree.deps, sub_tree)
            end
          elseif not target_exists or is_before(target_mtime, mtime(dep)) then
            if not is_directory(dep) then
              out_of_date = true
            end
          end
        end

        if satisfied_all_deps then
          if (all_deps_complete and rule.phony and rule.empty) or (target_exists and not out_of_date) then
            tree.complete = true
          end
          tree_cache[target] = tree
          return tree
        end
      end
    end

    if exists(target) then
      local tree = { target = target }
      tree.complete = true
      return tree
    end
  end

  return make_tree(target)
end
