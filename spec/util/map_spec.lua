describe('util.map', function()
  local map = require 'util.map'

  local function identity(x) return x end
  local function double(x) return 2 * x end

  it('should generate an empty list from an empty list', function()
    assert.are.same({}, map({}, identity))
  end)

  it('should generate a list from a non-empty list', function()
    assert.are.same({ 1, 2, 3 }, map({ 1, 2, 3 }, identity))
    assert.are.same({ 2, 4, 6 }, map({ 1, 2, 3 }, double))
  end)

  it('should not modify the input list', function()
    local input = { 1, 2, 3 }
    map(input, double)
    assert.are.same({ 1, 2, 3 }, input)
  end)

  it('should allow nil values to be returned by the mapping function', function()
    assert.are.same({}, map({ 1, 2, 3 }, load''))
  end)
end)
