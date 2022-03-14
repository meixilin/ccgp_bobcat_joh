#!/bin/bash
#$ -l highp,highmem,h_data=8G,h_vmem=INFINITY,h_rt=48:00:00
#$ -pe shared 8
#$ -wd <your working directory>/bobcat
#$ -o <your working directory>/bobcat/logs/paper_assembly/busco_comparisons/lynx_busco.out.txt
#$ -e <your working directory>/bobcat/logs/paper_assembly/busco_comparisons/lynx_busco.err.txt
#$ -m abe

# @version      v1
# @usage        qsub lynx_busco.sh
# @description  Run lynx busco comparisons
# Author: Meixi Lin
# Based on: Merly Escalona
# same commands and conda environments
# Date: 2022-02-20 12:48:20
# Update: shared cpu usage and don't download files multiple times

############################################################
## import packages
sleep $((RANDOM % 120))

eval "$(<your working directory>/miniconda3/bin/conda shell.bash hook)"
conda activate busco5

set -eo pipefail

############################################################
## def functions

############################################################
## def variables
# define species to work on
# the one on bobcat is not used for publication purposes
GENOMELIST=(\
'GCF_007474595.2_mLynCan4.pri.v2/GCF_007474595.2_mLynCan4.pri.v2_genomic.fasta' \
'GCA_022079265.1_mLynRuf1.p/GCA_022079265.1_mLynRuf1.p_genomic.fasta' \
'GCA_900661375.1_LYPA1.0/GCA_900661375.1_LYPA1.0_genomic.fasta')

HOMEDIR='<your working directory>/bobcat'
REFDIR='<your working directory>/bobcat/reference_genome'
WORKDIR=${HOMEDIR}/paper_assembly/busco_comparisons
mkdir -p ${WORKDIR}

TODAY=$(date "+%Y%m%d")
COMMITID=$(git --git-dir="${HOMEDIR}/.git" --work-tree="${HOMEDIR}" rev-parse master)

############################################################
## main
echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${JOB_ID}; GIT commit id ${COMMITID}"
which busco # confirm software versions

cd ${WORKDIR}

for genome in "${GENOMELIST[@]}"
do
    LOG="${genome:0:15}_mammalia_odb10_${TODAY}.log"
    echo -e "[$(date "+%Y-%m-%d %T")] Working on ${REFDIR}/${genome}"
    echo -e "[$(date "+%Y-%m-%d %T")] Working on ${REFDIR}/${genome}" > ${LOG}
    # if directory exists, don't download files again
    if [ -d busco_downloads/lineages/mammalia_odb10 ]
    then
        busco \
        -offline \
        --datasets_version odb10 \
        -c 8 \
        -m geno \
        -l mammalia \
        -i ${REFDIR}/${genome} \
        -o ${genome/\/*/} &>> ${LOG}
    else
        busco \
        --datasets_version odb10 \
        -c 8 \
        -m geno \
        -l mammalia \
        -i ${REFDIR}/${genome} \
        -o ${genome/\/*/} &>> ${LOG}
    fi
    echo -e "[$(date "+%Y-%m-%d %T")] Done"
    echo -e "[$(date "+%Y-%m-%d %T")] Done" >> ${LOG}
done

echo -e "[$(date "+%Y-%m-%d %T")] JOB ID ${JOB_ID}.${SGE_TASK_ID} Done"


