--
-- Pega o nome do arquivo passado como parâmetro (se houver)
--
local filename = ...
if not filename then
   print("Usage: lua interpretador.lua <prog.bpl>")
   os.exit(1)
end

local file = io.open(filename, "r")
if not file then
   print(string.format("[ERRO] Cannot open file %q", filename))
   os.exit(1)
end


--
-- regex para comparação
--
function regexComparacao(line)
  local comp = "==" -- regex pra igualdade
  local cmp = string.match(line, comp) -- vou armazenar o comparador em cmp
  if cmp ~= nil then
    return cmp
  end

  if cmp == nil then
    comp = "!="
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = ">="
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = "<="
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = "<"
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end

  if cmp == nil then
    comp = ">"
    cmp = string.match(line, comp)
    if cmp ~= nil then
      return cmp
    end
  end
end


--
-- regex do if
--
function regexIf(line)
  -- identifica se é um if
  local str = "if" 
  local verificaIf = string.match(line, str)
  
  -- identifica o lado esquerdo da operaçao                               
  local str2 = "if (%l*%d*%[?%-?%d*%]?)"
  local ladoesquerdo = string.match(line, str2)
  print(ladoesquerdo)

  -- identifica qual operador temos
  local cmp = regexComparacao(line) 
  print(cmp)
  
  -- identifica o lado direito da operaçao
  local str3 = "if %l*%d*%[?%-?%d*%]? " .. cmp .. " (%l*%d*%[?%-?%d*%]?)"
  local ladodireito = string.match(line, str3)
  print(ladodireito)
  
end


--
-- Imprime cada uma das linhas do arquivo
--
for line in file:lines() do
  -- print(line)
  regexIf(line)
end

file:close()