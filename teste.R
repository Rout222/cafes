#limpar workspace
rm(list=ls())
library("RSNNS")
library(SDMTools)
#limpar tela
cat('\014')
if(length(dev.list()) != 0){
  dev.off()  
}
data(iris)
labels <- decodeClassLabels(iris[,5])
encodeClassLabels(labels)