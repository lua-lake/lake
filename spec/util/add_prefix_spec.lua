describe('util.add_prefix', function()
  local add_prefix = require 'util.add_prefix'

  it('should add a prefix to provided strings', function()
    assert.are.equal('build/blah.o', add_prefix('build/')('blah.o'))
    assert.are.equal('output/this', add_prefix('output/')('this'))
  end)
end)
