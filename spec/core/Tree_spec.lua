describe('core.Tree', function()
  local proxyquire = require 'deps/proxyquire'
  local files
  local fs = {
    stat = function(file)
      return files[file]
    end
  }

  local Tree = proxyquire('core.Tree', {
    ['coro-fs'] = fs
  })

  before_each(function()
    files = {}
  end)

  it('should return nothing when there are no rules', function()
    local tree = Tree('foo', {}, {})

    assert.is_nil(tree)
  end)

  it('should return nothing when there is no rule for the target', function()
    local tree = Tree('foo', {
      { target = 'bar', deps = {} }
    }, {})

    assert.is_nil(tree)
  end)

  it('should return nothing when the target is not buildable because of a missing dependency', function()
    local tree = Tree('foo', {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} }
    }, {})

    assert.is_nil(tree)
  end)

  it('should create a completed tree when the target exists and is up-to-date', function()
    files = {
      foo = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      complete = true,
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should consider a target to be up-to-date if it is older than a dependency that is a directory', function()
    files = {
      foo = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 4, nsec = 0 }, type = 'directory' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar' } }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      complete = true,
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should create an incomplete tree when the target exists but is not up-to-date', function()
    files = {
      foo = { mtime = { sec = 1, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should create an incomplete tree when the target exists but is not up-to-date do to a simple dependency', function()
    files = {
      foo = { mtime = { sec = 4, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      qux = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = { 'qux' } },
      { target = 'baz', deps = {} },
      { target = 'qux', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {
        {
          target = 'bar',
          match = 'bar',
          rule = rules[2],
          deps = {}
        }
      }
    }, tree)
  end)

  it('should create an incomplete tree when the target exists but is not up-to-date due to nanoseconds', function()
    files = {
      foo = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 2, nsec = 1 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 1 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should create an incomplete tree when the target does not exist', function()
    files = {
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should create a completed tree when the target does not exist but is empty and phony', function()
    files = {
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' }, phony = true, empty = true },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      complete = true,
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should create an incomplete tree when the target does not exist and is phony', function()
    files = {
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' }, phony = true },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should create an incomplete tree when a dependency does not exist', function()
    files = {
      foo = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {
        {
          target = 'bar',
          match = 'bar',
          rule = rules[2],
          deps = {}
        }
      }
    }, tree)
  end)

  it('should create an incomplete tree when a dependency does not exist and the target is phony', function()
    files = {
      foo = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' }, phony = true },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {
        {
          target = 'bar',
          match = 'bar',
          rule = rules[2],
          deps = {}
        }
      }
    }, tree)
  end)

  it('should create a incomplete tree when the target and its dependencies do not exist', function()
    files = {}

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = {} }
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {
        {
          target = 'bar',
          match = 'bar',
          rule = rules[2],
          deps = {}
        },
        {
          target = 'baz',
          match = 'baz',
          rule = rules[3],
          deps = {}
        }
      }
    }, tree)
  end)

  it('should create multi-level trees', function()
    files = {
      quux = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = {} },
      { target = 'baz', deps = { 'qux' } },
      { target = 'qux', deps = { 'quux' } },
      { target = 'quux', deps = { } },
    }

    local tree = Tree('foo', rules, {})

    assert.are_same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {
        {
          target = 'bar',
          match = 'bar',
          rule = rules[2],
          deps = {}
        },
        {
          target = 'baz',
          match = 'baz',
          rule = rules[3],
          deps = {
            {
              target = 'qux',
              match = 'qux',
              rule = rules[4],
              deps = {}
            },
          }
        }
      }
    }, tree)
  end)

  it('should create trees with wildcard rules', function()
    files = {
      ['a.c'] = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      ['b.c'] = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'app.lib', deps = { 'a.o', 'b.o' } },
      { target = '*.o', deps = { '*.c' } }
    }

    local tree = Tree('app.lib', rules, {})

    assert.are_same({
      target = 'app.lib',
      match = 'app.lib',
      rule = rules[1],
      deps = {
        {
          target = 'a.o',
          match = 'a',
          rule = rules[2],
          deps = {}
        },
        {
          target = 'b.o',
          match = 'b',
          rule = rules[2],
          deps = {}
        }
      }
    }, tree)
  end)

  it('should ensure that identical sub-trees have reference equality', function()
    files = {}

    local rules = {
      { target = 'foo', deps = { 'bar', 'baz' } },
      { target = 'bar', deps = { 'qux' } },
      { target = 'baz', deps = { 'qux' } },
      { target = 'qux', deps = { } },
    }

    local tree = Tree('foo', rules, {})

    assert.are.equal(tree.deps[1].deps[1], tree.deps[2].deps[1])
  end)

  it('should build an incomplete tree for a target that is out of date due to a simple dependency', function()
    files = {
      foo = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 4, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar' } }
    }

    local simple_dependencies = {
      foo = { 'baz' }
    }

    local tree = Tree('foo', rules, simple_dependencies)

    assert.are.same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should build a complete tree for a target that is up-to-date with a simple dependency', function()
    files = {
      foo = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 1, nsec = 0 }, type = 'file' },
      baz = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar' } }
    }

    local simple_dependencies = {
      bar = { 'baz' }
    }

    local tree = Tree('foo', rules, simple_dependencies)

    assert.are.same({
      complete = true,
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {}
    }, tree)
  end)

  it('should treat missing simple dependencies as newer than the target', function()
    files = {
      foo = { mtime = { sec = 3, nsec = 0 }, type = 'file' },
      bar = { mtime = { sec = 2, nsec = 0 }, type = 'file' }
    }

    local rules = {
      { target = 'foo', deps = { 'bar' } },
    }

    local simple_dependencies = {
      foo = { 'baz' }
    }

    local tree = Tree('foo', rules, simple_dependencies)

    assert.are.same({
      target = 'foo',
      match = 'foo',
      rule = rules[1],
      deps = {}
    }, tree)
  end)
end)
