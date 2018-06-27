#limpar workspace
rm(list=ls())
library("RSNNS")
library("SDMTools")
library("caret")
library("devtools")
library("corrgram")

#limpar tela
cat('\014')
if(length(dev.list()) != 0){
  dev.off()  
}
set.seed(123)

dados <- read.table(
  "outputteste.csv",
  header=T,
  sep=",",
  colClasses=c(rep("numeric",5), "numeric")
)

padroniza <- function(s)
{
  retorno <- (as.double(s) - min(s))/(max(s) - min(s))
  
  return(retorno)
}

interv <- function(s)
{
  vet <- rep(NA, length(s))
  
  for (i in 1:length(s))
  {
    if (s[i]<=0.5)
      vet[i] <- 0
    else if (s[i]>0.5 && s[i]<=1.5)
      vet[i] <- 1
    else
      vet[i] <- 2
  }
  
  vet
}

#ANALISE DE DADOS
plot(dados$convexHull, col=dados$Classe+1, main="ConvexHull")
plot(dados$Rec, col=dados$Classe+1, main="Rectangle")
plot(dados$Elipse, col=dados$Classe+1, main="Elipse")
plot(dados$Circle, col=dados$Classe+1, main="Circle")
plot(dados$Area, col=dados$Classe+1, main="Area")

corrgram(dados[,-6], order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie,
         main="Correlograma das medidas")

x <- dados[,-6] # entradas

#CORRIGINDO O DATASET X PARA OUTRA ESCALA
x =  data.frame( #input que eu usei em python
  padroniza(x[,1]),
  padroniza(x[,5]/x[,2]),
  padroniza(x[,5]/x[,3]),
  padroniza(x[,5]/x[,4]),
  padroniza(x[,2]/x[,4]),
  padroniza(x[,2]/x[,3]),
  padroniza(x[,4]/x[,3])
)

colunas <- c("convexHull","Area/Elipse","Area/Rec","Area/Circ","Elipse/Circle","Elipse/Rec","Circle/Rec")

colnames(x) <- colunas

corrgram(x, order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie,
         main="Correlograma das medidas")

#Analise de dois componente altamente correlacionados
plot(x$`Elipse/Circ`, col="red")
par(new=T)
plot(x$`Area/Circ`, col="blue")

x <- x[,-4]

#Correlograma final do dataset finalizado
corrgram(x, order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie,
         main="Correlograma das medidas")

y <- dados$Classe # classes


#SEPARANDO AS AMOSTRAS DE TREINO, TESTE E VALIDACAO
classe1 <- x[1:597,]
classe2 <- x[598:904,]
classe3 <- x[905:988,]

#levando-se em conta a classe de menor tamanho (2)
#60 PC para treino
treino_c1 <- classe1[1:50,]
treino_c2 <- classe2[1:50,]
treino_c3 <- classe3[1:50,]

#20 PC para treino
teste_c1 <- classe1[51:68,]
teste_c2 <- classe2[51:68,]
teste_c3 <- classe3[51:68,]

#20 PC para treino
val_c1 <- classe1[69:84,]
val_c2 <- classe2[69:84,]
val_c3 <- classe3[69:84,]

#GERANDO O DATASET DE TREINO
colunas <- c("convexHull","Area/Elipse","Area/Rec","Elipse/Circle","Elipse/Rec","Circle/Rec","Classe")

treino <- cbind(rbind(treino_c1, treino_c2, treino_c3),
                c(rep(0,50),rep(1,50),rep(2,50)))
colnames(treino) <- colunas
treino <- treino[sample(nrow(treino)),]

#GERANDO O DATASET DE TESTE
teste <- cbind(rbind(teste_c1, teste_c2, teste_c3),
               c(rep(0,18),rep(1,18),rep(2,18)))
colnames(teste) <- colunas
teste <- teste[sample(nrow(teste)),]

#GERANDO O DATASET DE VALIDACAO
val <- cbind(rbind(val_c1, val_c2, val_c3),
             c(rep(0,16),rep(1,16),rep(2,16)))
colnames(val) <- colunas
val <- val[sample(nrow(val)),]

#PARAMETRIZAOCA DA REDE NEURAL
treina <- TRUE
nNeuronios = c(5, 25)
maxEpocas  = 15000
lr<- 0.055

RedeCA<- NULL
#TREINAMENTO DO MODELO
if (treina) 
{
  
  RedeCA<-mlp(treino[,-7], treino[,7], size=nNeuronios, maxit=maxEpocas, initFunc="Randomize_Weights",
              initFuncParams=c(-0.3, 0.3), learnFunc="Std_Backpropagation",
              learnFuncParams=c(lr), updateFunc="Topological_Order",
              updateFuncParams=c(0), hiddenActFunc="Act_Logistic",
              shufflePatterns=F, linOut=TRUE)
  
  saveRDS(RedeCA,"RedeCATreinada.rds")
}else{
  RedeCA <- readRDS("RedeCATreinada.rds")
}

plot(RedeCA$IterativeFitError,type="l",main="Erro da MLP CA")

#AVALIANDO AS PREVISÕES NO CONJUNTO DE TESTE
y <- treino[,7]
yhat <- interv(predict(RedeCA, treino[,-7]))

acertos_treino <- (length(which(y==yhat))*100)/length(y)

#AVALIANDO AS PREVISÕES NO CONJUNTO DE TESTE
y <- teste[,7]
yhat <- interv(predict(RedeCA, teste[,-7]))

acertos_teste <- (length(which(y==yhat))*100)/length(y)

#AVALIANDO AS PREVISOES NO CONJUNTO DE VALIDACAO
y <- val[,7]
yhat <- interv(predict(RedeCA, val[,-7]))

acertos_val <- (length(which(y==yhat))*100)/length(y)


#AVALIANDO AS PREVISOES EM TODA A AMOSTRA
y <- dados$Classe
yhat <- interv(predict(RedeCA, x))

acertos_total <- (length(which(y==yhat))*100)/length(y)

print(paste("TREINO:", acertos_treino))
print(paste("TESTE:", acertos_teste))
print(paste("VALIDACAO:", acertos_val))
print(paste("AMOSTRA:", acertos_total))