describe('util.exec', function()
  local proxyquire = require 'deps/proxyquire'

  local exit_code
  local pid

  local io_write = spy.new(load'')
  local spawn_waitExit = spy.new(function()
    return exit_code
  end)
  local spawn = spy.new(function()
    return {
      waitExit = spawn_waitExit,
      stdout = {
        read = function()
          return 'stdout output'
        end
      },
      stderr = {
        read = function()
          return 'stderr output'
        end
      },
      pid = pid
    }
  end)

  local exec = proxyquire('util.exec', {
    ['coro-spawn'] = spawn
  })

  before_each(function()
    io._write = io.write
    io.write = io_write
    exit_code = 0
    pid = 42
  end)

  after_each(function()
    io.write = io._write
  end)

  it('should spawn commands with no arguments', function()
    exec('ls')

    assert.spy(spawn).was_called_with('ls', match.is_same({ args = {} }))
    assert.spy(spawn_waitExit).was_called()
  end)

  it('should spawn commands with arguments', function()
    exec('mv abc 123')

    assert.spy(spawn).was_called_with('mv', match.is_same({ args = { 'abc', '123' } }))
    assert.spy(spawn_waitExit).was_called()
  end)

  it('should not print stdout by default', function()
    exec('mv abc 123')

    assert.spy(io_write).was_not_called_with('mv abc 123\n')
    assert.spy(io_write).was_called_with('stderr output')
    assert.spy(io_write).was_not_called_with('stdout output')
  end)

  it('should print stderr and stdout by when configured for verbose', function()
    exec('mv abc 123', true)

    assert.spy(io_write).was_called_with('mv abc 123\n')
    assert.spy(io_write).was_called_with('stderr output')
    assert.spy(io_write).was_called_with('stdout output')
  end)

  it('should raise an error when the exit code is non-zero', function()
    exit_code = 1
    assert.has_error(function()
      exec('mv abc 123')
    end, 'error executing mv abc 123')

    exit_code = -1
    assert.has_error(function()
      exec('mv abc 123')
    end, 'error executing mv abc 123')
  end)

  it('should raise an error when the command cannot be spawned', function()
    pid = 'not found'
    assert.has_error(function()
      exec('mv abc 123')
    end, 'error executing mv abc 123: not found')
  end)
end)
