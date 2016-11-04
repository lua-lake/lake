local getopt = require 'getopt'

return setmetatable({
  usage = 'usage: lake [-f <lakefile>=Lakefile] [-j <job_count>=1] [<target>=all]'
}, {
  __call = function(_, args)
    local options = {
      job_count = 1,
      lakefile = 'Lakefile'
    }

    for k, v in getopt('j:f:', unpack(args)) do
      if k == 'j' then
        options.job_count = tonumber(v)
      elseif k == 'f' then
        options.lakefile = v
      elseif k == false then
        if options.target then
          return
        end
        options.target = v
      else
        return
      end
    end

    options.target = options.target or 'all'

    return options
  end
})
