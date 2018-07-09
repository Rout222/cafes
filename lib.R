limpar <- function(){
  #limpar tela
  rm(list=ls())
  cat('\014')
  if(length(dev.list()) != 0){
    dev.off()  
  }
}
library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)
padroniza <- function(s)
{
  retorno <- (as.double(s) - min(s))/(max(s) - min(s))
  return(retorno)
}


salvarPlot <- function(obj, nome, path){
  png(nome , width = 1500, height = 1333)
  transparentTheme(trans = .4)
  print(obj)
  dev.off()
}

plotaGraficos <- function(prints, size){
  multiplot(plotlist = prints, cols=2)
}
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL, nome = "output.jpg") {
  library(grid)
  theme_set(theme_bw()) 
  # Make a list from the ... arguments and plotlist
  plots <- c(plotlist)
  print(plotlist)
  numPlots = length(plots)
  print(numPlots)
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  png(nome , width = 1500, height = 1333)
  if (numPlots==1) {
    print(plots[[1]])
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
  dev.off()
}