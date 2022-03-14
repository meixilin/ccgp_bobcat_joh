# Title: Plot bobcat phylogeny tree
# Author: Meixi Lin
# Date: Wed Feb 16 12:33:56 2022

# preparation --------
rm(list = ls())
cat("\014")
options(echo = TRUE, stringsAsFactors = FALSE)

setwd('<your working directory>/figures/fig1c')

library(ggtree)
library(ggplot2)
library(dplyr)
sessionInfo()

# main --------
# from johnson et al. 2006
tree <- read.tree(text='(((Iberian Lynx\n L. pardinus:1.18,Eurasian lynx\n Lynx lynx:1.18):0.43,Canada lynx\n L. canadensis:1.61):1.63,Bobcat\n L. rufus:3.24):1;')

# plotting
pp <- ggtree(tree) +
    geom_tiplab(offset = 0.1) +
    geom_rootedge() +
    theme_tree2()

pp1 <- revts(pp)

# add a label dt
labdt <- pp1$data %>%
    dplyr::filter(isTip == FALSE) %>%
    dplyr::mutate(nodelab = abs(x),
                  y_dodge = y+0.1,
                  x_dodge = x-0.23)

# add a color on IUCN and genome status
dotdt0 <- data.frame(label = c("IberianLynx\nL.pardinus","Eurasianlynx\nLynxlynx","Canadalynx\nL.canadensis","Bobcat\nL.rufus"),
                     IUCN = c('EN','LC','LC','LC'),
                     Genome = c('Yes','No','Yes','This study'))
dotdt <- pp1$data %>%
    dplyr::filter(isTip == TRUE) %>%
    dplyr::left_join(., y = dotdt0, by = 'label') %>%
    dplyr::mutate(nodelab = abs(x),
                  x_dodge = x-0.2)

pp2 <- pp1+
    geom_text(data = labdt, mapping = aes(x=x_dodge,y=y_dodge,label=nodelab)) +
    geom_point(data = dotdt, mapping = aes(x=x,y=y,color=IUCN), size = 3) +
    scale_color_manual(values = c('darkred', 'deepskyblue2')) +
    geom_point(data = dotdt, mapping = aes(x=x_dodge,y=y,fill=Genome), size = 3, shape = 22) +
    scale_fill_manual(values = c('darkgrey', 'green', 'darkolivegreen')) +
    theme(axis.text.x = element_text(size = 12),
          legend.position = 'top') +
    scale_x_continuous(breaks=-3:0, labels=3:0, limits = c(-4.3,1.2),name = 'Divergence Time (Mya)')

pp2

# output files --------
ggsave(filename = 'fig1c_phylogeny.pdf', plot = pp2, height = 5, width = 5)
save.image(file = 'fig1c_20220223.RData')

# cleanup --------
date()
closeAllConnections()



