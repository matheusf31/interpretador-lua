str0 = "print()"
str1 = "print(12)"
str2 = "print(x)"
str3 = "print(a[-2])"
str4 = "print(a[-1])"
str5 = "print(a[100])"
str6 = "foo()"
str7 = "bar(x)"
str8 = "joao(a,b)"
str9 = "maria(a,b,as)"
str10 = "pedro(a[-1],b[2])"

padrao = "((%l+)%((%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?),?(%l*%d*%[?%-?%d*%]?)%))" 

assinatura, nomefuncao, p1, p2, p3 = string.match(str10,padrao)	

print(assinatura,nomefuncao,p1,p2,p3)

