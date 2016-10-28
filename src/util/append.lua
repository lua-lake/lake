return function(base, to_append)
  for _, v in ipairs(to_append) do
    table.insert(base, v)
  end
end
