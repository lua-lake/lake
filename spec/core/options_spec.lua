describe('core.options', function()
  local proxyquire = require 'deps/proxyquire'

  local options = proxyquire('core.options', {
    getopt = require 'deps/getopt'
  })

  it('should provide the usage string', function()
    assert.are.equal('usage: lake [-f <lakefile>=Lakefile] [-j <job_count>=1] [<target>=all]', options.usage)
  end)

  it('should default the lakefile to "Lakefile"', function()
    assert.are.equal('Lakefile', options({}).lakefile)
  end)

  it('should allow the lakefile to be set via -f', function()
    assert.are.equal('lake.lk', options({ '-flake.lk' }).lakefile)
    assert.are.equal('jake.lk', options({ '-f', 'jake.lk' }).lakefile)
  end)

  it('should not allow -f to be used without an argument', function()
    assert.is_nil(options({ '-f' }))
  end)

  it('should default the job count to 1', function()
    assert.are.equal(1, options({}).job_count)
  end)

  it('should allow the job count to be set via -j', function()
    assert.are.equal(8, options({ '-j8' }).job_count)
    assert.are.equal(6, options({ '-j', '6' }).job_count)
  end)

  it('should not allow -j to be used without an argument', function()
    assert.is_nil(options({ '-j' }))
  end)

  it('should default the target to "all"', function()
    assert.are.equal('all', options({}).target)
  end)

  it('should not allow multiple targets', function()
    assert.is_nil(options({ 'all', 'some' }))
  end)

  it('should allow the target to be set', function()
    assert.are.equal('some', options({ 'some' }).target)
    assert.are.equal('none', options({ 'none' }).target)
  end)

  it('should not allow undefined arguments', function()
    assert.is_nil(options({ '-k' }))
    assert.is_nil(options({ '-k3' }))
  end)

  it('should allow config items to be passed via the command line', function()
    assert.are.same({ x = '1', y = '2', a_b_c = 'hello' }, options({ 'x=1', 'y=2', 'a_b_c=hello' }).config)
  end)

  it('should not allow config items without values', function()
    assert.is_nil(options({ 'x=', 'all' }))
  end)

  it('should not allow values without a config item name', function()
    assert.is_nil(options({ '=1', 'all' }))
  end)

  it('should yield an empty config table if no config items are provided', function()
    assert.are.same({}, options({ 'all' }).config)
  end)

  it('should allow all options to be used together', function()
    assert.are.same({
      job_count = 8,
      lakefile ='target.lk',
      target = 'some',
      config = { a = 'hello' }
    }, options({ '-j8', '-f', 'target.lk', 'some', 'a=hello' }))
  end)
end)
