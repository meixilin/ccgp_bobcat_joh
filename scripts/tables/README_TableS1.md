# run gff3 summary for LYPA1.0

```bash
conda activate bobcatassembly
python3 scripts/paper_assembly/tables/TableS1_parse_LYPA1.0_gff3.py
```

# glimpse the gff3 file

```
##gff-version 3
#!gff-spec-version 1.21
#!processor NCBI annotwriter
#!genome-build LYPA1.0
#!genome-build-accession NCBI_Assembly:GCA_900661375.1
##sequence-region CAAGRJ010000001.1 1 13188378
##species https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=191816
CAAGRJ010000001.1       EMBL    region  1       13188378        .       +       .       ID=CAAGRJ010000001.1:1..13188378;Dbxref=taxon:191816;gbkey=Src;mol_type=genomic DNA;note=contig: lp23s00001
CAAGRJ010000001.1       EMBL    gene    1       1802    .       -       .       ID=gene-LYPA_23REPC000000001;Name=LYPA_23REPC000000001;gbkey=Gene;gene_biotype=other;locus_tag=LYPA_23REPC000000001
CAAGRJ010000001.1       EMBL    repeat_region   1       1802    .       -       .       ID=id-LYPA_23REPC000000001;Note=L1_Carn1;gbkey=repeat_region;locus_tag=LYPA_23REPC000000001;rpt_family=LINE
```

# output

```
############################################################
GCA_900661375.1_LYPA1.0 - <your working directory>/bobcat/reference_genome/GCA_900661375.1_LYPA1.0/GCA_900661375.1_LYPA1.0_genomic.gff.gz
--------
False
type           gene_biotype    gbkey              count
gene           other           Gene             4711188
repeat_region  .               repeat_region    4711188
CDS            .               CDS               323375
exon           .               exon              216197
region         .               Src                41700
exon           .               mRNA               28522
mRNA           .               mRNA               28522
gene           protein_coding  Gene               21160
exon           .               ncRNA               4898
lnc_RNA        .               ncRNA               4898
gene           lncRNA          Gene                3733
dtype: int64
```

Important lines:
type           gene_biotype    gbkey              count
gene           protein_coding  Gene               **21160**
CDS            .               CDS               **323375**