describe('util.set_extension', function()
  local set_extension = require 'util.set_extension'

  it('should replace the extension on a filename', function()
    assert.are.equal('hello.o', set_extension('o')('hello.c'))
  end)

  it('should add an extension if the provided filename has none', function()
    assert.are.equal('goodbye.x', set_extension('x')('goodbye'))
  end)

  it('should work correctly when the filename has more than one period', function()
    assert.are.equal('ciao.a.c', set_extension('c')('ciao.a.b'))
  end)
end)
