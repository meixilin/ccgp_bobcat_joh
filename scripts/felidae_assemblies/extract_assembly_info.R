# Title: Extract assembly info from xml file in NCBI download
# Author: Meixi Lin
# Date: Tue Feb 22 12:38:15 2022

# preparation --------
rm(list = ls())
cat("\014")
options(echo = TRUE, stringsAsFactors = FALSE)

setwd("<your working directory>/felidae_assemblies/")

library(XML)
library(dplyr)

# def functions --------
extract_meta <- function(meta, myvar) {
    # extract the metadata line
    splitmeta = strsplit(meta, split = '<Stat category=')[[1]]
    varmeta = grep(x = splitmeta, pattern = myvar, value = TRUE)
    varvalue = strsplit(varmeta, split = '>')[[1]][2]
    varvalue = strsplit(varvalue, split = '</Stat')[[1]][1]
    varvalue = as.numeric(varvalue)
    return(varvalue)
}
# def variables --------

# load data --------
assembly = xmlToDataFrame(doc = 'Assemblies/assembly_result_felidae_20220222.xml')
lineage = read.csv(file = 'Lineages/Revised_felidae_IUCN.csv', row.names = 1)

# change two assembly species names that does not match IUCN revisions
assembly$SpeciesNameIUCN = assembly$SpeciesName
assembly$SpeciesNameIUCN[assembly$SpeciesNameIUCN == 'Puma yagouaroundi'] = 'Herpailurus yagouaroundi'
assembly$SpeciesNameIUCN[assembly$SpeciesNameIUCN == 'Prionailurus iriomotensis'] = 'Prionailurus bengalensis' # pg.28 in IUCN report

# arrange by refseq
assembly$RefSeq_category = factor(assembly$RefSeq_category, levels = c('representative genome', 'na'))

# arrange the assembly by species name, refseq category and last update time
assembly = assembly %>%
    dplyr::mutate(LastUpdateDate = as.Date(LastUpdateDate, "%Y/%m/%d %H:%M")) %>%
    dplyr::arrange(SpeciesNameIUCN, RefSeq_category, desc(LastUpdateDate))

# add some statistics in the meta section
for (ii in 1:nrow(assembly)) {
    assembly$total_length[ii] = extract_meta(meta = assembly$Meta[ii], myvar = 'total_length')
}

# main --------
combined = lineage
statsvar = c('Taxid','SpeciesName','Organism','AssemblyStatus','SubmissionDate','RefSeq_category',
             'Coverage','ContigN50','ScaffoldN50', 'total_length')
combined[,c('AssemblyAvailable', 'AssemblyAccessions','RepAssemblyAccession', statsvar)] <- NA
assembly[,'matched_lineage'] <- NA
for (ii in 1:nrow(combined)) {
    species = combined[ii, 'Species']
    this_assembly = assembly[assembly$SpeciesNameIUCN == species,]
    assembly[assembly$SpeciesNameIUCN == species, 'matched_lineage'] = TRUE
    if (nrow(this_assembly) > 0) {
        combined[ii, 'AssemblyAvailable'] = TRUE
        combined[ii, 'AssemblyAccessions'] = paste(this_assembly$AssemblyAccession, collapse = ';')
        combined[ii, 'RepAssemblyAccession'] = this_assembly[1,'AssemblyAccession']
        combined[ii, statsvar] = this_assembly[1, statsvar]
        combined[ii, 'RefSeq_category'] = as.character(this_assembly[1, 'RefSeq_category'])
    } else {
        combined[ii, 'AssemblyAvailable'] = FALSE
    }
}

# add summary stats ========
sink(file = 'summary_felidae_assembly_percent_20220222.log')
options(echo = TRUE)
table(combined$AssemblyAvailable)
combined %>%
    dplyr::group_by(Genus) %>%
    dplyr::summarise(sum = sum(AssemblyAvailable))

combined %>%
    dplyr::group_by(Lineage) %>%
    dplyr::summarise(sum_assembly = sum(AssemblyAvailable),
                     n_species = n()) %>%
    dplyr::mutate(percent_assembly = sum_assembly/n_species)
sink()

# output files --------
write.csv(assembly, file = 'Assemblies/assembly_result_felidae_20220222.csv')
write.csv(combined, file = 'summary_felidae_assembly_20220222.csv')

# cleanup --------
date()
closeAllConnections()
