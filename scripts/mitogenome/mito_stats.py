# -*- coding: utf-8 -*-
'''
Title: parse four mitochondrion genbank for table S1 in bobcat genome assembly release paper
Author: Meixi Lin
Date: 2022-02-20 17:39:25
Usage:
> conda activate bobcatassembly
> python3 mito_stats.py
'''
import sys
import Bio
from Bio import SeqIO
from Bio.SeqUtils import GC

def get_stats(seq_record):
    seqid = seq_record.id
    seqdes = seq_record.description
    seqlen = len(seq_record)
    gcper = GC(seq_record.seq)
    # get counts
    countlist = []
    for ii in "ATCGN":
        countlist.append(seq_record.seq.count(ii))
    if sum(countlist) != seqlen:
        raise ValueError('Unknown bases not counted')
    # get percents
    percentlist = [ii/seqlen for ii in countlist]
    # format output results
    outstring = '{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n'.format(
        seqid,
        str(seqlen),
        str(gcper),
        '\t'.join([str(ii) for ii in countlist]),
        '\t'.join([str(ii) for ii in percentlist]),
        seqdes)
    return outstring

def main():
    # list of the statistics collected
    resheader = ['SeqID', 'Seq_Len', 'GC_percent', 'A_count', 'T_count', 'C_count', 'G_count', 'N_count', 'A_percent', 'T_percent', 'C_percent', 'G_percent', 'N_percent', 'Description']
    # genbank files
    gbfile = '<your working directory>/bobcat/paper_assembly/mitogenome/mitogenome_lynx.gb'
    outfile = '<your working directory>/bobcat/paper_assembly/mitogenome/mitogenome_lynx_summary.txt'

    with open(outfile,'w') as outf:
        outf.write('\t'.join(resheader)+'\n')

        for seq_record in SeqIO.parse(gbfile, "genbank"):
            outf.write(get_stats(seq_record))

sys.exit(main())