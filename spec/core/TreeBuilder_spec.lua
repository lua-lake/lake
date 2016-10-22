describe('core.TreeBuilder', function()
  local build = require 'core.TreeBuilder'({
    schedule = function(job) job() end
  }).build

  local mach = require 'deps/mach'

  local foo_builder = mach.mock_function('foo_builder')
  local bar_builder = mach.mock_function('bar_builder')
  local baz_builder = mach.mock_function('baz_builder')
  local qux_builder = mach.mock_function('qux_builder')

  local function nothing_should_happen()
    return mach.mock_function():may_be_called()
  end

  before_each(function()
    rules = {
      { builder = foo_builder, subscribers = {} },
      { builder = bar_builder, subscribers = {} },
      { builder = baz_builder, subscribers = {} },
      { builder = qux_builder, subscribers = {} }
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
    foo_builder:should_be_called_with('foo', 'foo-match'):when(function()
      build({
        target = 'foo',
        match = 'foo-match',
        rule = rules[1],
        deps = {}
      })
    end)
  end)

  it('should build a tree with one dependency', function()
    bar_builder:should_be_called_with('bar', 'bar-match'):
      and_then(foo_builder:should_be_called_with('foo', 'foo-match')):
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
    bar_builder:should_be_called_with('bar', 'bar-match'):
      and_also(baz_builder:should_be_called_with('baz', 'baz-match')):
      and_then(foo_builder:should_be_called_with('foo', 'foo-match')):
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
    qux_builder:should_be_called_with('qux', 'qux-match'):
      and_then(baz_builder:should_be_called_with('baz', 'baz-match')):
      and_then(foo_builder:should_be_called_with('foo', 'foo-match')):
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

    qux_builder:should_be_called_with('qux', 'qux-match'):
      and_then(bar_builder:should_be_called_with('bar', 'bar-match')):
      and_also(baz_builder:should_be_called_with('baz', 'baz-match')):
      and_then(foo_builder:should_be_called_with('foo', 'foo-match')):
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
end)
