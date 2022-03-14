# Title: Plot coverage by scaffold in lynx genomes
# Author: Meixi Lin
# Date: Sun Feb 20 13:08:08 2022
# Modified on 2022-03-11 16:34:58

# preparation --------
rm(list = ls())
cat("\014")
options(echo = TRUE, stringsAsFactors = FALSE)

setwd("<your working directory>/paper_assembly/figures/fig1d/")

library(dplyr)
library(ggplot2)

# def functions --------
read_assemblyreport <- function(infile) {
    indt = read.delim(file = infile, comment.char = "#",
                      header = FALSE, stringsAsFactors = FALSE)
    # find colnames
    inlines = readLines(con = infile)
    headline = inlines[max(grep(pattern = '^#', x = inlines))]
    headnames = strsplit(sub('# ','',x=headline),split = '\t')[[1]]
    # replace `-` with `_`
    headnames = gsub(pattern = '-',replacement = '_',x = headnames)
    colnames(indt)=headnames
    return(indt)
}

get_cumsum <- function(indt) {
    # get sum length
    genomesize = sum(indt$Sequence_Length)
    # sort by length
    outdt = indt %>%
        dplyr::arrange(desc(Sequence_Length))
    # get cumulative sum length
    cumsum = c()
    for (ii in 1:nrow(outdt)) {
        tempsum = sum(outdt$Sequence_Length[1:ii])
        cumsum = c(cumsum,tempsum)
    }
    outdt$Cumulative_Length = cumsum
    outdt$Cumulative_Coverage = outdt$Cumulative_Length/genomesize
    outdt = outdt[,c('Sequence_Length','Cumulative_Coverage','GenomeName', 'Assigned_Molecule')]
    outdt$Assigned_Molecule[outdt$Assigned_Molecule == 'na'] = NA_character_
    # add the starting positions
    startline = outdt[1,]
    startline$Cumulative_Coverage = 0
    outdt = rbind(startline, outdt)
    return(outdt)
}

get_chrnamedt <- function(plotdt) {
    chrnamedt = plotdt[plotdt$Assigned_Molecule %in% c('A1','C1','B1','A2','C2'), ]
    chrnamedt = chrnamedt[-1,]
    cumsum = chrnamedt$Cumulative_Coverage[1]/2
    for (ii in 2:nrow(chrnamedt)) {
        tempsum = (chrnamedt$Cumulative_Coverage[ii] + chrnamedt$Cumulative_Coverage[ii-1])/2
        cumsum = c(cumsum,tempsum)
    }
    chrnamedt = chrnamedt %>%
        dplyr::mutate(Sequence_Length = Sequence_Length-10000000)
    chrnamedt$Cumulative_Coverage = cumsum
    return(chrnamedt)
}

# def variables --------
reportfiles = c("./data/GCA_022079265.1_mLynRuf1.p_assembly_report.txt",
               "./data/GCF_007474595.2_mLynCan4.pri.v2_assembly_report.txt",
               "./data/GCA_900661375.1_LYPA1.0_assembly_report.txt")
names(reportfiles) = c("mLynRuf1.p","mLynCan4.pri.v2","LYPA1.0")

# load data --------
# load three reports
reportdtlist = lapply(reportfiles, read_assemblyreport)
# check the report columns are the same
all(c(colnames(reportdtlist[[1]]) == colnames(reportdtlist[[2]]),
      colnames(reportdtlist[[1]]) == colnames(reportdtlist[[3]])))

# add the genomename
for (ii in seq_along(reportdtlist)){
    genomename = names(reportdtlist)[ii]
    reportdtlist[[ii]]$GenomeName = genomename
}

# main --------
# get cumulative sums
cumsumdtlist = lapply(reportdtlist, get_cumsum)
plotdt = dplyr::bind_rows(cumsumdtlist)

# make an annotate layer
chrnamedt = get_chrnamedt(plotdt)

# plot the output ========
pp <- ggplot(plotdt,aes(x = Cumulative_Coverage, y = Sequence_Length/1e+6,
                        color = GenomeName)) +
    scale_color_brewer(palette = 'Dark2') +
    geom_step(direction = 'vh') +
    geom_vline(xintercept = 0.5, linetype = 'dashed') +
    geom_text(data = chrnamedt, aes(label = Assigned_Molecule)) +
    annotate("text", x = 0.20, y = 240, label = "Lynx rufus", color = '#7570B3') +
    annotate("text", x = 0.35, y = 220, label = "L. canadensis", color = '#D95F02') +
    annotate("text", x = 0.20, y = 15, label = "L. pardinus", color = '#1B9E77') +
    labs(x = 'Cumulative Coverage',
         y = 'Scaffold Size (Mb)') +
    scale_x_continuous(expand = expansion(mult = c(0, .05))) +
    theme_bw() +
    theme(text = element_text(size = 12),
          axis.text = element_text(size = 12),
          legend.position = 'none',
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank())

# output files --------
ggsave(filename = 'fig1d_NGx_R.pdf', plot = pp, height = 5, width = 5)
save.image(file = 'data/fig1d_20220311.RData')

# cleanup --------
date()
closeAllConnections()
