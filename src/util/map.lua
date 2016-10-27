return function(xs, f)
  local mapped = {}
  for _, x in ipairs(xs) do
    table.insert(mapped, f(x))
  end
  return mapped
end
