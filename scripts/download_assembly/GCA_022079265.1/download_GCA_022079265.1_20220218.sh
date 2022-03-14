#!/bin/bash
#$ -l highp,h_data=4G,h_rt=48:00:00
#$ -wd <your working directory>/bobcat
#$ -o <your working directory>/bobcat/logs/stepx_reference_genome/download_GCA_022079265.1_20220218.out.txt
#$ -e <your working directory>/bobcat/logs/stepx_reference_genome/download_GCA_022079265.1_20220218.err.txt
#$ -m abe

# @version      v0
# @usage        qsub download_GCA_022079265.1_20220218.sh
# @description  Download Bobcat reference genome Genbank version and check md5sum
# https://www.ncbi.nlm.nih.gov/assembly/GCA_022079265.1/
# https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/022/079/265/GCA_022079265.1_mLynRuf1.p/
# Author: Meixi Lin
# Date: 2022-02-18 00:42:19

############################################################
## import packages
set -xeo pipefail

############################################################
## def functions

############################################################
## def variables
HOMEDIR='<your working directory>/bobcat'
WORKDIR='<your working directory>/bobcat/reference_genome'
FTPDIR='ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/022/079/265/'
REFNAME='GCA_022079265.1_mLynRuf1.p'
AR_REFERENCE_SEQ=${REFNAME}_genomic.fna.gz  # to archive
REFERENCE_SEQ=${REFNAME}_genomic.fasta

COMMITID=$(git --git-dir="${HOMEDIR}/.git" --work-tree="${HOMEDIR}" rev-parse master)

############################################################
## main
echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${JOB_ID}; GIT commit id ${COMMITID}"
mkdir -p ${WORKDIR}

cd ${WORKDIR}

wget -nv -r ${FTPDIR}${REFNAME}/
echo $?

mv ./ftp.ncbi.nlm.nih.gov/genomes/all/GCA/022/079/265/${REFNAME} ${REFNAME}
rm -r ./ftp.ncbi.nlm.nih.gov

# gunzip file
cd ${REFNAME}/
cp ${AR_REFERENCE_SEQ} ${AR_REFERENCE_SEQ/.fna.gz/.fasta.gz}
gunzip ${REFERENCE_SEQ}.gz

# md5sum check
md5sum --check md5checksums.txt

echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${JOB_ID} Done"

