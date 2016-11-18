return function(extension)
  return function(filename)
    if filename:match('%.') then
      return (filename:gsub('^(.*)%.[^%.]+$', '%1%.' .. extension))
    else
      return filename .. '.' .. extension
    end
  end
end
