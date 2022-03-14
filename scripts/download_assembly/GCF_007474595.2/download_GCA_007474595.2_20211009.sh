#!/bin/bash
#$ -l highp,h_data=4G,h_rt=48:00:00
#$ -wd <your working directory>/bobcat
#$ -o <your working directory>/bobcat/logs/stepx_reference_genome/download_GCA_007474595.2_20211009.out.txt
#$ -e <your working directory>/bobcat/logs/stepx_reference_genome/download_GCA_007474595.2_20211009.err.txt
#$ -m abe

# @version      v0
# @usage        qsub download_GCA_007474595.2_20211009.sh
# @description  Download Canadian Lynx reference genome Genbank version and check md5sum
# https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/007/474/595/GCA_007474595.2_mLynCan4.pri.v2/
# Author: Meixi Lin
# Date: Sat Oct  9 16:30:29 2021

############################################################
## import packages
set -xeo pipefail

############################################################
## def functions

############################################################
## def variables
HOMEDIR='<your working directory>/bobcat'
WORKDIR='<your working directory>/bobcat/reference_genome'
FTPDIR='ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/007/474/595/'
REFNAME='GCA_007474595.2_mLynCan4.pri.v2'
AR_REFERENCE_SEQ='GCA_007474595.2_mLynCan4.pri.v2_genomic.fna.gz'  # to archive
REFERENCE_SEQ='GCA_007474595.2_mLynCan4.pri.v2_genomic.fasta'

COMMITID=$(git --git-dir="${HOMEDIR}/.git" --work-tree="${HOMEDIR}" rev-parse master)

############################################################
## main
echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${JOB_ID}; GIT commit id ${COMMITID}"
mkdir -p ${WORKDIR}

cd ${WORKDIR}

wget -nv -r ${FTPDIR}${REFNAME}/
echo $?

mv ./ftp.ncbi.nlm.nih.gov/genomes/all/GCA/007/474/595/GCA_007474595.2_mLynCan4.pri.v2/ GCA_007474595.2_mLynCan4.pri.v2/
rm -r ./ftp.ncbi.nlm.nih.gov

# gunzip file
cd GCA_007474595.2_mLynCan4.pri.v2/
cp ${AR_REFERENCE_SEQ} ${AR_REFERENCE_SEQ/.fna.gz/.fasta.gz}
gunzip ${REFERENCE_SEQ}.gz

# md5sum check
md5sum --check md5checksums.txt

echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${JOB_ID} Done"
