local line = "func()"
local rgx = "(%l+%[?%-?%d*%]?) (=) " .. if (regexfunccall(line) == nil) "(%l+%d*%[?%-?%d*%]?)" : regexfunccall(line)
local variavel, attr, arg = string.match("var = ", rgx)
print(variavel)

function regexfunccall(line)
  local str = line
  return str
end