-- caso a variável não estelocalVariavela no escopo atual procuramos na função chamada anteriormente, simulação de escopo dinâmico 
-- #pilha + localVariavel, é a posição em que se encontra a variável

-- primeiro vamos extrair o localLadoEsquerdo

-- pegar lado esquerdo
transformaLado(localLadoEsquerdo, ladoEsquerdoOperacao, posicaoVetor)

-- se operação for nula, significa que estamos fazendo uma atribuição
if op == nil then
  
  -- DIZ RESPEITO SE O LADO ESQUERDO É UMA FUNÇÃO
  if string.match(ladoEsquerdoOperacao,"%l+%(") then
  
  -- regexChamadaFuncao(line)
  -- return true
  
  -- verificar se A VARIAVEL é um vetor // SE ENTRAR AQUI ELA NÃO É UM VETOR
  elseif posicaoVetor == nil or posicaoVetor == "" then
    -- trata a = 12 (um numero), ou seja quando o lado esquerdo é um 
    if tonumber(ladoesquerdo) ~= nil
      tabelafuncoes[pilha[#pilha+localVariavel]][variavel] = tonumber(ladoEsquerdoOperacao)
    else
      -- trata a = b, ou seja quando o lado esquedo é uma variavel
      tabelafuncoes[pilha[#pilha+localVariavel]][variavel] = ladoEsquerdoOperacao
    end
  
  -- se nossa VARIAVEL for um VETOR a gente faz outro tipo de atribuição
  else
    -- corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores positivos
    posicaoVetor = tonumber(posicaoVetor)
    if posicaoVetor >= 0 then
      posicaoVetor = corrigeVetorPositivo(posicaoVetor)
      --print(type(posicaoVetor))
      tabelafuncoes[pilha[#pilha+localVariavel]][variavel][posicaoVetor] = ladoEsquerdoOperacao
    -- corrige a diferença do vetor que existe entre lua e a linguagem do bruno para valores negativos
    else
      posicaoVetor = corrigeVetorNegativo(posicaoVetor, #tabelafuncoes[pilha[#pilha+localVariavel]][variavel])
      tabelafuncoes[pilha[#pilha+localVariavel]][variavel][posicaoVetor] = ladoEsquerdoOperacao
    end
  end
  
  return true

-- CASO SEJA UMA OPERAÇÃO
else
  -- regex que identifica o lado direito da operação                                                                                 -- vv essa é a parte que queremos vv
  rgx3 = "[%+%-%*%/]%s+(%l*%d*%[?%-?%d*%]?%(?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?,?%l*%d*%[?%-?%d*%]?%)?)"
  ladoDireitoOperacao = string.match(line, rgx3)
  print(variavel, attr, ladoEsquerdoOperacao, op, ladoDireitoOperacao)
  -- ARRUMAR RETORNO posso retornar a operacao que está sendo feita
end