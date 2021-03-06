options(warn=-1)
#limpar workspace
rm(list=ls())
library("RSNNS")
library(SDMTools)
#limpar tela
cat('\014')
if(length(dev.list()) != 0){
  dev.off()  
}


library(AppliedPredictiveModeling)

library(caret)
dados <- read.table(
  "output.csv",
  header=T,
  sep=",",
  colClasses=c(rep("numeric",5), "character")
)

x <- dados[,-length(dados)] # retira a classificação
inputTeste =  data.frame( #input que eu usei em python
  x[,1],
  x[,2]/x[,5],
  x[,3]/x[,5],
  x[,4]/x[,5],
  x[,2]/x[,4],
  x[,2]/x[,3],
  x[,4]/x[,3]
)
intervalo <- function(x, min, max){
  x[which(x > max)] <- max
  x[which(x < min)] <- min
  x
}
input1 =  data.frame( #input que eu usei em python
  intervalo(x[,1],	350,1200),
  intervalo(x[,5]/x[,2],0.87,	0.99),
  intervalo(x[,5]/x[,3],0.74,	0.78),
  intervalo(x[,5]/x[,4],0.38,	0.74),
  intervalo(x[,2]/x[,4],0.4,	0.74),
  intervalo(x[,2]/x[,3],	0.78,0.84),
  intervalo(x[,4]/x[,3],	1.06,2.29)
)
colnames(input1) <- c("Area", "%Elipse", "%Rec", "%Circle", "E/C", "E/R", "C/R")
colnames(inputTeste) <- c("Area", "%Elipse", "%Rec", "%Circle", "E/C", "E/R", "C/R")
y <- factor(dados$Classe) # classificaçao


gerarGraficos <- function(input, expected, nome){
  png(paste('plots/',nome,'-pairs.png') , width = 1500, height = 1333)
  attach(mtcars)
  transparentTheme(trans = .4)
  obj <- featurePlot(input,
              expected,
              plot = "pairs",
              ## Add a key at the top
              auto.key = list(columns = 3))
  print(obj)
  dev.off()
  png(paste('plots/',nome,'-box.png') , width = 1500, height = 1333)
  attach(mtcars)
  obj <- featurePlot(input, 
              expected, 
              plot = "box", 
              ## Pass in options to bwplot() 
              scales = list(y = list(relation="free"),
                            x = list(rot = 90)),  
              layout = c(4,2 ), 
              auto.key = list(columns = 2))
  transparentTheme(trans = .9)
  print(obj)
  dev.off()
  png(paste('plots/',nome,'-density.png') , width = 1500, height = 1333)
  attach(mtcars)
  obj <- featurePlot(x = input, 
              y = expected,
              plot = "density", 
              ## Pass in options to xyplot() to 
              ## make it prettier
              scales = list(x = list(relation="free"), 
                            y = list(relation="free")), 
              adjust = 1.5, 
              pch = "|", 
              layout = c(4, 2), 
              auto.key = list(columns = 3))
  print(obj)
  dev.off()
}
print("Gerando graficos")
gerarGraficos(x,y, "x")
gerarGraficos(inputTeste,y, "input teste")
gerarGraficos(input1,y, "input 1")
print("Pronto!")