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
  "outputteste.csv",
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
  size    = length(indices)
  treino = 1:(floor(0.6*size))
  teste1 = (floor(0.6*size)+1):(floor(0.8*size))
  teste2 = (floor(0.8*size)+1):size
  indicesDeTreino = c(indicesDeTreino, indices[treino])
  indicesDeTeste1 = c(indicesDeTeste1, indices[teste1])
  indicesDeTeste2 = c(indicesDeTeste2, indices[teste2])
}

input <- x
input =  data.frame( #input que eu usei em python
  x[,1],
  x[,5]/x[,2],
  x[,5]/x[,3],
  x[,5]/x[,4],
  x[,2]/x[,4],
  x[,2]/x[,3],
  x[,4]/x[,3]
)
# for (i in seq(1,length(input))) {
#   input[,i] = padroniza(input[,i])
# }

for (i in seq(1,length(x))) {
  input[,i] = padroniza(input[,i])
}
output <- decodeClassLabels(y)

nNeuronios = c(5,5,5,5)
maxEpocas  = 10000

lr<- 0.08
file <- "output.txt"
# for (i in seq(0.07, 0.09, 0.01)) {
  RedeCA<- NULL
  RedeCA<-mlp(input[indicesDeTreino,], output[indicesDeTreino,], size=nNeuronios, maxit=maxEpocas, initFunc="Randomize_Weights",
              initFuncParams=c(-0.3, 0.3), learnFunc="Std_Backpropagation",
              learnFuncParams=c(0.08), updateFunc="Topological_Order",
              updateFuncParams=c(0), hiddenActFunc="Act_Logistic",
              shufflePatterns=T, linOut=TRUE)
  
  library(caret)
  #print(confusionMatrix(data = yat, reference = yy, mode = "prec_recall"))
  CMtreino <- confusionMatrix(
    factor(encodeClassLabels(fitted.values(RedeCA))),
    factor(encodeClassLabels(output[indicesDeTreino,]))
  )
  
  CMteste1 <- confusionMatrix(
    factor(encodeClassLabels(predict(RedeCA,input[indicesDeTeste1,]))),
    factor(encodeClassLabels(output[indicesDeTeste1,]))
  )
  
  CMteste2 <- confusionMatrix(
    factor(encodeClassLabels(predict(RedeCA,input[indicesDeTeste2,]))),
    factor(encodeClassLabels(output[indicesDeTeste2,]))
  )
  CMtodos <- confusionMatrix(
    factor(encodeClassLabels(predict(RedeCA,input))),
    factor(encodeClassLabels(output))
  )
  
  # if(acc < CMtodos$overall[1]){
  #   acc <- CMtodos$overall[1]
  #   melhor <- lr
    plot(RedeCA$IterativeFitError,type="l",main="Erro da MLP CA")
    write(
      paste( "Erro da ultima época, " ,RedeCA$IterativeFitError[maxEpocas]),
      file = file,
      append = FALSE)
    
    write(
      lr,
      file = file,
      append = TRUE)
    
    
    #plotar mlp
    library(devtools)
    source_url('https://gist.githubusercontent.com/fawda123/7471137/raw/466c1474d0a505ff044412703516c34f1a4684a5/nnet_plot_update.r')
    
    #plot each model
    #plot.nnet(RedeCA)
    
    write.table(as.matrix(CMtreino), file = file,
                append = TRUE, sep = "\t",row.names = FALSE,
                col.names = FALSE)
    write.table(CMtreino$overall[1], file = file,
                append = TRUE, sep = "\t",row.names = TRUE,
                col.names = FALSE)
    write.table(as.matrix(CMteste1), file = file,
                append = TRUE, sep = "\t",row.names = FALSE,
                col.names = FALSE)
    write.table(CMteste1$overall[1], file = file,
                append = TRUE, sep = "\t",row.names = TRUE,
                col.names = FALSE)
    write.table(as.matrix(CMteste2), file = file,
                append = TRUE, sep = "\t",row.names = FALSE,
                col.names = FALSE)
    write.table(CMteste2$overall[1], file = file,
                append = TRUE, sep = "\t",row.names = TRUE,
                col.names = FALSE)
    write(
      "De todos juntos",
      file = file,
      append = TRUE)
    write.table(as.matrix(CMtodos), file = file,
                append = TRUE, sep = "\t",row.names = FALSE,
                col.names = FALSE)
    write.table(CMtodos$overall[1], file = file,
                append = TRUE, sep = "\t",row.names = TRUE,
                col.names = FALSE)
#   }
# }