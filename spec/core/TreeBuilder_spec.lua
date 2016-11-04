describe('core.TreeBuilder', function()
  local build = require 'core.TreeBuilder'({
    schedule = function(job) job() end
  }).build

  local mach = require 'deps/mach'
  local match = mach.match

  local foo_builder = mach.mock_function('foo_builder')
  local bar_builder = mach.mock_function('bar_builder')
  local baz_builder = mach.mock_function('baz_builder')
  local qux_builder = mach.mock_function('qux_builder')
  local pattern_builder = mach.mock_function('pattern_builder')

  local rules

  local function nothing_should_happen()
    return mach.mock_function():may_be_called()
  end

  before_each(function()
    rules = {
      { builder = foo_builder, deps = { 'foo-dep1', 'foo-dep2' }, subscribers = {} },
      { builder = bar_builder, deps = { 'foo-dep1', 'foo-dep2' }, subscribers = {} },
      { builder = baz_builder, deps = { 'foo-dep1', 'foo-dep2' }, subscribers = {} },
      { builder = qux_builder, deps = { 'foo-dep1', 'foo-dep2' }, subscribers = {} },
      { builder = pattern_builder, deps = { '*-dep1', '*-dep2' }, subscribers = {} }
    }
  end)

  it('should do nothing for a completed tree', function()
    nothing_should_happen():when(function()
      build({
        target = 'foo',
        match = 'foo-match',
        complete = true,
        rule = rules[1],
        deps = {}
      })
    end)
  end)

  it('should build a tree with no dependencies', function()
    foo_builder:should_be_called_with(match({
      target = 'foo',
      match = 'foo-match',
      deps = rules[1].deps
    })):
      when(function()
        build({
          target = 'foo',
          match = 'foo-match',
          rule = rules[1],
          deps = {}
        })
      end)
  end)

  it('should build a tree with one dependency', function()
    bar_builder:should_be_called_with(match({
      target = 'bar',
      match = 'bar-match',
      deps = rules[2].deps
    })):
      and_then(foo_builder:should_be_called_with(match({
        target = 'foo',
        match = 'foo-match',
        deps = rules[1].deps
      }))):
      when(function()
        build({
          target = 'foo',
          match = 'foo-match',
          rule = rules[1],
          deps = {
            {
              target = 'bar',
              match = 'bar-match',
              rule = rules[2],
              deps = {}
            }
          }
        })
      end)
  end)

  it('should build a tree with multiple dependencies', function()
    bar_builder:should_be_called_with(match({
      target = 'bar',
      match = 'bar-match',
      deps = rules[2].deps
    })):
      and_also(baz_builder:should_be_called_with(match({
        target = 'baz',
        match = 'baz-match',
        deps = rules[3].deps
      }))):
      and_then(foo_builder:should_be_called_with(match({
        target = 'foo',
        match = 'foo-match',
        deps = rules[1].deps
      }))):
      when(function()
        build({
          target = 'foo',
          match = 'foo-match',
          rule = rules[1],
          deps = {
            {
              target = 'bar',
              match = 'bar-match',
              rule = rules[2],
              deps = {}
            },
            {
              target = 'baz',
              match = 'baz-match',
              rule = rules[3],
              deps = {}
            }
          }
        })
      end)
  end)

  it('should build a tree with multiple nested dependencies', function()
    qux_builder:should_be_called_with(match({
      target = 'qux',
      match = 'qux-match',
      deps = rules[4].deps
    })):
      and_then(baz_builder:should_be_called_with(match({
        target = 'baz',
        match = 'baz-match',
        deps = rules[3].deps
      }))):
      and_then(foo_builder:should_be_called_with(match({
        target = 'foo',
        match = 'foo-match',
        deps = rules[1].deps
      }))):
      when(function()
        build({
          target = 'foo',
          match = 'foo-match',
          rule = rules[1],
          deps = {
            {
              target = 'baz',
              match = 'baz-match',
              rule = rules[3],
              deps = {
                {
                  target = 'qux',
                  match = 'qux-match',
                  rule = rules[4],
                  deps = {}
                }
              }
            }
          }
        })
      end)
  end)

  it('should build a tree with multiple paths to the same dependency', function()
    local shared_dep = {
      target = 'qux',
      match = 'qux-match',
      rule = rules[4],
      deps = {}
    }

    qux_builder:should_be_called_with(match({
      target = 'qux',
      match = 'qux-match',
      deps = rules[4].deps
    })):
      and_then(bar_builder:should_be_called_with(match({
        target = 'bar',
        match = 'bar-match',
        deps = rules[2].deps
      }))):
      and_also(baz_builder:should_be_called_with(match({
        target = 'baz',
        match = 'baz-match',
        deps = rules[3].deps
      }))):
      and_then(foo_builder:should_be_called_with(match({
        target = 'foo',
        match = 'foo-match',
        deps = rules[1].deps }))):
      when(function()
        build({
          target = 'foo',
          match = 'foo-match',
          rule = rules[1],
          deps = {
            {
              target = 'bar',
              match = 'bar-match',
              rule = rules[2],
              deps = {
                shared_dep
              }
            }, {
              target = 'baz',
              match = 'baz-match',
              rule = rules[3],
              deps = {
                shared_dep
              }
            }
          }
        })
      end)
  end)

  it('should provide actual dependency names when building a pattern rule', function()
    pattern_builder:should_be_called_with(match({
      target = 'pattern',
      match = 'match',
      deps = { 'match-dep1', 'match-dep2' }
    })):
      when(function()
        build({
          target = 'pattern',
          match = 'match',
          rule = rules[5],
          deps = {}
        })
      end)
  end)
end)
