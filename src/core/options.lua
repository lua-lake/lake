local getopt = require 'getopt'

return setmetatable({
  usage = 'usage: lake [-f <lakefile>=Lakefile] [-j <job_count>=1] [<target>=all]'
}, {
  __call = function(_, args)
    local options = {
      job_count = 1,
      lakefile = 'Lakefile',
      config = {},
      targets = {}
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
          table.insert(options.targets, v)
        end
      else
        return
      end
    end

    if #options.targets == 0 then options.targets = { 'all' } end

    return options
  end
})
