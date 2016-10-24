describe('util.append', function()
  local append = require 'util.append'

  it('should append an empty array to an empty array', function()
    local t = {}
    append(t, {})
    assert.are.same({}, t)
  end)

  it('should append a non-empty array to an empty array', function()
    local t = {}
    append(t, { 1, 2, 3 })
    assert.are.same({ 1, 2, 3 }, t)
  end)

  it('should append an empty array to a non-empty array', function()
    local t = { 'a', 'b', 'c' }
    append(t, {})
    assert.are.same({ 'a', 'b', 'c' }, t)
  end)

  it('should append a non-empty array to a non-empty array', function()
    local t = { 1, 2, 3 }
    append(t, { 4, 5, 6 })
    assert.are.same({ 1, 2, 3, 4, 5, 6 }, t)
  end)

  it('should not modify the array that was appended to the base', function()
    local t = { 4, 2 }
    append({ 1, 2, 3 }, t)
    assert.are.same({ 4, 2 }, t)
  end)
end)
