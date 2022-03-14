# -*- coding: utf-8 -*-
'''
# Title: parse custom gff3 files to report number of genes, transcripts and CDS for table S1 in bobcat genome assembly release paper
# Author: Meixi Lin
# Date: 2022-02-17 15:33:18
Usage:
> conda activate bobcatassembly
> python3 TableS1_parse_LYPA1.0_gff3.py
'''
# https://scikit-allel.readthedocs.io/en/stable/io.html#gff3

import sys

import allel

def main():
    gffpath='<your working directory>/bobcat/reference_genome/GCA_900661375.1_LYPA1.0/GCA_900661375.1_LYPA1.0_genomic.gff.gz'
    gffname='GCA_900661375.1_LYPA1.0'

    # load the gffdt
    gffdt = allel.gff3_to_dataframe(path = gffpath, attributes = ['ID','Parent','gene_biotype', 'protein_id','gbkey'])
    print('############################################################')
    print('{0} - {1}'.format(gffname, gffpath))
    print('--------')
    # check that the ID and locations are unique
    # keep = False mark all duplicates as true
    print(any(gffdt.duplicated(subset=['seqid','start','end','ID'], keep=False)))
    # check the value counts
    print(gffdt.value_counts(subset=['type','gene_biotype','gbkey']))
# define counts
# protein_coding genes: type == gene, gene_biotype == protein_coding --> 21160
# cds: type == CDS --> 323375
# genes and pseudogenes: not defined

if __name__ == "__main__":
    sys.exit(main())


