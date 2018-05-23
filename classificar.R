#limpar workspace
rm(list=ls())
library("RSNNS")
#limpar tela
cat('\014')
dados <- read.table(
  "output.csv",
  header=T,
  sep=",",
  colClasses=c(rep("numeric",5))
  )

#funçoes basicas

gerarGraficos <- function(df,nome){
  png(paste('plots/',nome,'-plot.png'))
  attach(mtcars)
  layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE), 
         widths=c(3,1), heights=c(1,2))
  plot(df, type="p", xlab="data", ylab="valor", main=nome)
  
  hist(df$x, main=paste("Histograma"))
  
  boxplot(df$x, main=paste("Boxplot"))
  dev.off()
}
x <- dados[,-5] # retira a classificação
y <- dados$Classe # classificaçao


#gerar os gráficos
col <- c("DistanciaMaiorDefeito","AreaMinElipse","AreaMinRec","AreaMinCircle")

for (i in seq(1,length(x))) {
  df <- data.frame(x[i],y)
  colnames(df) <- c("x","y")
  gerarGraficos(df, col[i])  
}

indicesDeTreino = NULL
indicesDeTeste1 = NULL
indicesDeTeste2 = NULL

#separa os indices em 3 grupos, de 60%, 20%, 20%, por tipo
for (i in seq(1,3)) {
  indices = which(y==(i-1))
  indices = sample(indices)
  size    = length(indices)
  treino = 1:(floor(0.6*size))
  teste1 = (floor(0.6*size)+1):(floor(0.8*size))
  teste2 = (floor(0.8*size)+1):size
  indicesDeTreino = c(indicesDeTreino, indices[treino])
  indicesDeTeste1 = c(indicesDeTeste1, indices[teste1])
  indicesDeTeste2 = c(indicesDeTeste2, indices[teste2])
}

nNeuronios = 20
maxEpocas  = 30000
RedeCA<-mlp(x[indicesDeTreino,], y[indicesDeTreino], size=nNeuronios, maxit=maxEpocas, initFunc="Randomize_Weights",
            initFuncParams=c(-0.3, 0.3), learnFunc="Std_Backpropagation",
            learnFuncParams=c(0.051), updateFunc="Topological_Order",
            updateFuncParams=c(0), hiddenActFunc="Act_Logistic",
            shufflePatterns=F, linOut=TRUE)

plot(RedeCA$IterativeFitError,type="l",main="Erro da MLP CA")
print(paste( "Erro quadrado médio do treino, " ,mean(sqrt((y-predict(RedeCA, x))^2))))
