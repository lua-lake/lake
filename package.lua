return {
  name = 'lua-lake/lake',
  version = '0.0.1',
  dependencies = {
    'creationix/coro-spawn@2.0.0',
    'creationix/coro-fs@2.2.1',
    'luvit/pretty-print@2.0.0',
    'ryanplusplus/proxyquire@1.0.2'
  },
  files = {
    '**.lua',
    '!sample/**.lua',
    '!spec/**.lua'
  },
  description = 'Make-like build system, but with Lua.',
  tags = {},
  license = 'MIT',
  author = { name = 'Ryan Hartlage' },
  homepage = 'https://github.com/lua-lake/lake',
}
