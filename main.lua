local bundle = require 'luvi'.bundle
loadstring(bundle.readfile('luvit-loader.lua'), 'bundle:luvit-loader.lua')()

local uv = require 'uv'

require './lake'(args)

uv.run()
