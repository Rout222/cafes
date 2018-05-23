#limpar workspace
rm(list=ls())

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

col <- c("DistanciaMaiorDefeito","AreaMinElipse","AreaMinRec","AreaMinCircle")

for (i in seq(1,length(x))) {
  df <- data.frame(x[i],y)
  colnames(df) <- c("x","y")
  gerarGraficos(df, col[i])  
}

