local map = require './map'
local flatten = require './flatten'

return function(xs, f)
  return flatten(map(xs, f))
end
