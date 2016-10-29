describe('util.flat_map', function()
  local flat_map = require 'util.flat_map'

  local function identity(x) return x end
  local function double(x) return 2 * x end

  it('should generate an empty list from an empty list', function()
    assert.are.same({}, flat_map({}, identity))
  end)

  it('should generate a list from a non-empty list', function()
    assert.are.same({ 1, 2, 3 }, flat_map({ 1, 2, 3 }, identity))
    assert.are.same({ 2, 4, 6 }, flat_map({ 1, 2, 3 }, double))
  end)

  it('should not modify the input list', function()
    local input = { 1, 2, 3 }
    flat_map(input, double)
    assert.are.same({ 1, 2, 3 }, input)
  end)

  it('should flatten the generated list', function()
    assert.are.same({ 1, 2, 3, 4, 5, 6 }, flat_map({ { 1, 2 }, { 3, 4 }, { 5, 6 } }, identity))
  end)

  it('should flatten the generated list recursively', function()
    assert.are.same({ 1, 2, 3, 4, 5, 6 }, flat_map({ { 1, { 2, 3 } }, { 4 }, { 5, { 6 } } }, identity))
  end)
end)
