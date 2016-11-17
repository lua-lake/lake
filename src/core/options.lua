local getopt = require 'getopt'

return setmetatable({
  usage = 'usage: lake [-f <lakefile>=Lakefile] [-j <job_count>=1] [<target>=all]'
}, {
  __call = function(_, args)
    local options = {
      job_count = 1,
      lakefile = 'Lakefile',
      config = {}
    }

    for k, v in getopt('j:f:', unpack(args)) do
      if k == 'j' then
        options.job_count = tonumber(v)
      elseif k == 'f' then
        options.lakefile = v
      elseif k == false then
        local config, value = v:match('^([%w_]+)=([%w_]+)$')
        if config and value then
          options.config[config] = value
        else
          if options.target then
            return
          end
          options.target = v
        end
      else
        return
      end
    end

    options.target = options.target or 'all'

    return options
  end
})
