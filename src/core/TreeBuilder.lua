return function(job_queue)
  local function execute(tree)
    if not tree.complete then
      tree.complete = true
      local deps = {}
      for _, dep in ipairs(tree.rule.deps) do
        table.insert(deps, (dep:gsub('*', tree.match)))
      end
      tree.rule.builder({
        target = tree.target,
        match = tree.match,
        deps = deps
      })
      for _, subscriber in ipairs(tree.rule.subscribers[tree.target] or {}) do
        subscriber()
      end
    end
  end

  local function build_tree(tree)
    if tree.scheduled or tree.complete then return end

    tree.scheduled = true

    local todo_dep_count = 0
    local deps_to_build = {}

    local function dep_completed()
      todo_dep_count = todo_dep_count - 1
      if todo_dep_count == 0 then
        execute(tree)
      end
    end

    for _, dep in ipairs(tree.deps) do
      if not dep.complete then
        todo_dep_count = todo_dep_count + 1
        dep.rule.subscribers[dep.target] = dep.rule.subscribers[dep.target] or {}
        table.insert(dep.rule.subscribers[dep.target], dep_completed)
        table.insert(deps_to_build, dep)
      end
    end

    for _, dep in ipairs(deps_to_build) do
      job_queue.schedule(function()
        build_tree(dep)
      end)
    end

    if todo_dep_count == 0 then
      execute(tree)
    end
  end

  return {
    build = build_tree
  }
end
