local map = require './src/util/map'
local flatten = require './src/util/flatten'

return function(xs, f)
  return flatten(map(xs, f))
end
