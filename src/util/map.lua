return function(xs, f)
  local mapped = {}
  for _, x in ipairs(xs) do
    local value = f(x)
    if value then
      table.insert(mapped, value)
    end
  end
  return mapped
end
