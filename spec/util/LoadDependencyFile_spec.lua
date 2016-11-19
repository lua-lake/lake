describe('util.LoadDependencyFile', function()
  local proxyquire = require 'deps/proxyquire'
  local files

  local LoadDependencyFile = proxyquire('util.LoadDependencyFile', {
    ['coro-fs'] = {
      readFile = function(filename)
        return files[filename]
      end
    }
  })
  local RuleSet = require 'core.RuleSet'

  local load_dependency_file
  local rule_set


  before_each(function()
    rule_set = RuleSet()
    load_dependency_file = LoadDependencyFile(rule_set)
  end)

  it('should successfully load a file with no rules', function()
    files = { abc = '' }

    load_dependency_file('abc')

    assert.are.same({}, rule_set.simple_dependencies)
  end)

  it('should successfully load a file with a single, simple rule', function()
    files = {
      ['hello.d'] = [[
hello.c: hello.h
      ]]
    }

    load_dependency_file('hello.d')

    assert.are.same({
      ['hello.c'] = { 'hello.h' }
    }, rule_set.simple_dependencies)
  end)

  it('should successfully load a file with a single rule', function()
    files = {
      ['hello.d'] = [[
hello.c: hello.h goodbye.h
      ]]
    }

    load_dependency_file('hello.d')

    assert.are.same({
      ['hello.c'] = { 'hello.h', 'goodbye.h' }
    }, rule_set.simple_dependencies)
  end)

  it('should successfully load a file with multiple rules', function()
    files = {
      ['deps.d'] = [[
hello.c: hello.h goodbye.h

goodbye.c: goodbye.h foo.h
      ]]
    }

    load_dependency_file('deps.d')

    assert.are.same({
      ['hello.c'] = { 'hello.h', 'goodbye.h' },
      ['goodbye.c'] = { 'goodbye.h', 'foo.h' }
    }, rule_set.simple_dependencies)
  end)

  it('should successfully load a file with line continuations', function()
    files = {
      ['deps.d'] = [[
hello.c: hello.h \
  goodbye.h \
  foo.h

goodbye.c: \
  goodbye.h \
  foo.h
      ]]
    }

    load_dependency_file('deps.d')

    assert.are.same({
      ['hello.c'] = { 'hello.h', 'goodbye.h', 'foo.h' },
      ['goodbye.c'] = { 'goodbye.h', 'foo.h' }
    }, rule_set.simple_dependencies)
  end)

  it('should ignore missing files', function()
    files = {}

    load_dependency_file('deps.d')

    assert.are.same({}, rule_set.simple_dependencies)
  end)
end)
