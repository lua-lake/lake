local map = require 'util.map'
local flatten = require 'util.flatten'

return function(xs, f)
  return flatten(map(xs, f))
end
