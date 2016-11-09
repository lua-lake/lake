describe('util.include', function()
  local include = require 'util.include'

  before_each(function()
    bar = spy.new(load'')
  end)

  it('should load the specified file in the current environment', function()
    local foo = spy.new(load'')

    include('spec/util/include_helper.lua')
    assert.spy(foo).was_called_with(1, 2, 3)
    assert.spy(bar).was_called_with('a', 'b', 'c')
  end)

  it('should load a relative file in the current environment', function()
    local foo = spy.new(load'')

    include('./include_helper.lua')
    assert.spy(foo).was_called_with(1, 2, 3)
    assert.spy(bar).was_called_with('a', 'b', 'c')
  end)

  it('should load a relative file in the current environment', function()
    local foo = spy.new(load'')

    include('./include_helper.lua')
    assert.spy(foo).was_called_with(1, 2, 3)
    assert.spy(bar).was_called_with('a', 'b', 'c')
  end)

  it('should allow a file to be loaded with a custom environment', function()
    local env = {
      foo = spy.new(load'')
    }

    include('./include_helper.lua', env)
    assert.spy(env.foo).was_called_with(1, 2, 3)
    assert.spy(bar).was_not_called()
  end)

  it('should not include locals in custom environments', function()
    local env = {
      foo = spy.new(load'')
    }
    local bar = spy.new(load'')

    include('./include_helper.lua', env)
    assert.spy(env.foo).was_called_with(1, 2, 3)
    assert.spy(bar).was_not_called()
  end)

  it('should not allow the loaded file to modify a custom environment', function()
    local env = {
      foo = spy.new(load'')
    }
    local bar = spy.new(load'')

    include('./include_helper.lua', env)
    assert.is_nil(env.baz)
  end)

  it('should return the return value of the included file', function()
    local foo = spy.new(load'')

    assert.are.equal(5, include('spec/util/include_helper.lua'))
  end)
end)
