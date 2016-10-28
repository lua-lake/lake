describe('util.files_from_directory', function()
  local proxyquire = require 'deps/proxyquire'

  local fs_mock = {
    scandir = function(dir)
      --[[
        top/
          sub1/
            file1
            file2
          sub2/
            file3
            sub3/
              file4
          file5
      ]]
      local data = {
        top = {
          { name = 'sub1', type = 'directory' },
          { name = 'sub2', type = 'directory' },
          { name = 'file5', type = 'file' }
        },
        ['top/sub1'] = {
          { name = 'file1', type = 'file' },
          { name = 'file2', type = 'file' }
        },
        ['top/sub2'] = {
          { name = 'file3', type = 'file' },
          { name = 'sub3', type = 'directory' }
        },
        ['top/sub2/sub3'] = {
          { name = 'file4', type = 'file' }
        }
      }

      return coroutine.wrap(function()
        for _, v in ipairs(data[dir]) do
          coroutine.yield(v)
        end
      end)
    end
  }

  local files_from_directory = proxyquire('util.files_from_directory', {
    ['coro-fs'] = fs_mock
  })

  it('should be able to get files from a directory with a single file', function()
    assert.are.same({ 'top/sub2/file3' }, files_from_directory('top/sub2'))
  end)

  it('should be able to get files from a directory with a single file', function()
    assert.are.same({ 'top/sub1/file1', 'top/sub1/file2' }, files_from_directory('top/sub1'))
  end)

  it('should be able to get files from a directory with a mix of files and subdirectories', function()
    assert.are.same({ 'top/file5' }, files_from_directory('top'))
  end)

  it('should be able to get files from a directory recursively', function()
    local expected = {
      'top/sub1/file1',
      'top/sub1/file2',
      'top/sub2/file3',
      'top/sub2/sub3/file4',
      'top/file5'
    }
    assert.are.same(expected, files_from_directory('top', { recursive = true }))
  end)

  it('should be able to get files from a directory that match a pattern', function()
    local expected = {
      'top/sub2/file3',
      'top/sub2/sub3/file4'
    }
    assert.are.same(expected, files_from_directory('top', {
      recursive = true,
      match = 'sub2'
    }))
  end)

  it('should be able to get files from a directory that match at least one of multiple patterns', function()
    local expected = {
      'top/sub1/file1',
      'top/sub1/file2',
      'top/sub2/file3',
      'top/sub2/sub3/file4'
    }
    assert.are.same(expected, files_from_directory('top', {
      recursive = true,
      match = { 'sub2', 'sub1', 'file1' }
    }))
  end)
end)
