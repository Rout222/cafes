#limpar workspace
rm(list=ls())
library("RSNNS")
library(SDMTools)
#limpar tela
cat('\014')
if(length(dev.list()) != 0){
  dev.off()  
}
set.seed(123)

dados <- read.table(
  "output.csv",
  header=T,
  sep=",",
  colClasses=c(rep("numeric",5), "numeric")
  )
intervalo <- function(x, min, max){
  x[which(x > max)] <- max
  x[which(x < min)] <- min
  x
}
padroniza <- function(s)
{
  retorno <- (as.double(s) - min(s))/(max(s) - min(s))
  
  return(retorno)
}
ajustaOutliers <- function(x, na.rm = TRUE, ...) 
{
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  
  for(i in 1:length(y)) 
  {
    #caso o primeiro valor seja NA procura o proximo valor nao NA e coloca
    #no lugar do NA
    if (is.na(y[1]) == TRUE)
    {
      encontrou = FALSE
      cont = 1
      posterior = NA
      #procura o primeiro numero POSTERIOR ao valor atual que nao seja NA
      while (encontrou == FALSE)
      {
        if (is.na(y[1+cont]) == TRUE)
        {
          cont <- cont + 1
        }
        else
        {
          posterior <- y[1+cont];
          encontrou <- TRUE
        }
      }
      
      y[1] <- posterior
    }
    
    #caso o ultimo valor seja NA procura o primeiro valor anterior que nao NA e coloca
    #no lugar do NA
    if (is.na(y[length(y)]) == TRUE)
    {
      encontrou <- FALSE
      cont <- 1
      anterior <- NA
      
      #procura o primeiro numero ANTERIOR ao valor atual que nao seja NA
      while (encontrou == FALSE)
      {
        if (is.na(y[length(y)-cont]) == TRUE)
        {
          cont <- cont + 1
        }
        else
        {
          anterior <- y[length(y)-cont];
          encontrou <- TRUE
        }
      }
      
      y[length(y)] <- anterior
    }
    
    
    
    if (is.na(y[i])==TRUE)
    {
      encontrou <- FALSE
      cont <- 1
      anterior <- NA
      
      #procura o primeiro numero ANTERIOR ao valor atual que nao seja NA
      while (encontrou == FALSE)
      {
        if (is.na(y[i-cont]) == TRUE)
        {
          cont <- cont + 1
        }
        else
        {
          anterior <- y[i-cont];
          encontrou <- TRUE
        }
      }
      
      encontrou = FALSE
      cont = 1
      posterior = NA
      
      #procura o primeiro numero POSTERIOR ao valor atual que nao seja NA
      while (encontrou == FALSE)
      {
        if (is.na(y[i+cont]) == TRUE)
        {
          cont <- cont + 1
        }
        else
        {
          posterior <- y[i+cont];
          encontrou <- TRUE
        }
      }
      
      #executa uma media entre o anterior e posterior valor valido na serie e insere no lugar do outlier
      y[i] <- (anterior+posterior)/2
    }
  }
  
  return(y)}
#funçoes basicas

x <- dados[,-length(dados)] # retira a classificação


y <- dados$Classe # classificaçao
#y <- factor(dados$Classe) # classificaçao


#gerar os gráficos
col <- c("DistanciaMaiorDefeito","AreaMinElipse","AreaMinRec","AreaMinCircle")

# for (i in seq(1,length(x))) {
#   x[,i] <- ajustaOutliers(x[,i])  
# }

indicesDeTreino = NULL
indicesDeTeste1 = NULL
indicesDeTeste2 = NULL

#separa os indices em 3 grupos, de 60%, 20%, 20%, por tipo
for (i in unique(y)) {
  indices = which(y==(i))
  # indices = sample(indices)
  size    = length(indices)
  treino = 1:(floor(0.6*size))
  teste1 = (floor(0.6*size)+1):(floor(0.8*size))
  teste2 = (floor(0.8*size)+1):size
  indicesDeTreino = c(indicesDeTreino, indices[treino])
  indicesDeTeste1 = c(indicesDeTeste1, indices[teste1])
  indicesDeTeste2 = c(indicesDeTeste2, indices[teste2])
}


# input =  data.frame( #input que eu usei em python
#   intervalo(x[,1],	350,1200),
#   intervalo(x[,5]/x[,2],0.87,	0.99),
#   intervalo(x[,5]/x[,3],0.74,	0.78),
#   intervalo(x[,5]/x[,4],0.38,	0.74),
#   intervalo(x[,2]/x[,4],0.4,	0.74),
#   intervalo(x[,2]/x[,3],	0.78,0.84),
#   intervalo(x[,4]/x[,3],	1.06,2.29)
# )
# for (i in seq(1,length(input))) {
#   input[,i] = padroniza(input[,i])
# }

for (i in seq(1,length(x))) {
  x[,i] = padroniza(x[,i])
}
output <- decodeClassLabels(y)



nNeuronios = 50
maxEpocas  = 30000

RedeCA<- NULL
RedeCA<-mlp(x[indicesDeTreino,], output[indicesDeTreino,], size=nNeuronios, maxit=maxEpocas, initFunc="Randomize_Weights",
            initFuncParams=c(-0.3, 0.3), learnFunc="Std_Backpropagation",
            learnFuncParams=c(0.3), updateFunc="Topological_Order",
            updateFuncParams=c(0), hiddenActFunc="Act_Logistic",
            shufflePatterns=T, linOut=TRUE)

plot(RedeCA$IterativeFitError,type="l",main="Erro da MLP CA")
print(paste( "Erro da ultima época, " ,RedeCA$IterativeFitError[maxEpocas]))


#print(confusionMatrix(data = yat, reference = yy, mode = "prec_recall"))
print(confusionMatrix(
  factor(encodeClassLabels(fitted.values(RedeCA))),
  factor(encodeClassLabels(output[indicesDeTreino,]))
))

