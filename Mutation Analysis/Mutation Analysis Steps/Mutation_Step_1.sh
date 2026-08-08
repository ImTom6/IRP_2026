#!/usr/bin/bash
#SBATCH --job-name=Avida_Mutation_Analysis_Part_1
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=04:00:00
#SBATCH --mem=32gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of fgbio (https://github.com/fulcrumgenomics/fgbio) [Version 1.5.1]
#Local installation of picard (https://github.com/broadinstitute/picard) [Version 2.20.1]
#Htslib on HPC for gunzip [Version 1.17-xwll33g]

############################################

#Adapted from Avida DNA Targeted Sequencing Analysis Technical Guide to work for hg38
#(https://www.agilent.com/cs/library/usermanuals/public/G9409-90001.pdf)

#NAME OF DIRECTORY (Change name)
sid=

#Add full directory path
sample_dn=/$sid

mkdir -p $sample_dn/readstats


#Load modules
module load R
module load htslib

#Load local modules (Set Paths)
fgbio=/Modules/fgbio-1.5.1.jar
picard=/Modules/picard.jar


############################################

#PART 1

#Prep Files
gunzip $sample_dn/R1.fq.gz
gunzip $sample_dn/R2.fq.gz

#1. Convert FASTQ files to BAM file
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $picard FastqToSam \
FASTQ=$sample_dn/R1.fq FASTQ2=$sample_dn/R2.fq \
OUTPUT=$sample_dn/raw_unmapped.bam \
READ_GROUP_NAME=$sid SAMPLE_NAME=$sid \
LIBRARY_NAME=pe PLATFORM=illumina PLATFORM_UNIT=HiSeq \
MAX_RECORDS_IN_RAM=1000000

#2. Extract UMIs from BAM file 
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio ExtractUmisFromBam \
--input=$sample_dn/raw_unmapped.bam \
--output=$sample_dn/raw_unmapped_umi.bam \
--read-structure=3M2S146T 3M2S146T --molecular-index-tags=ZA ZB --single-tag=RX

#3. Mark Illumina adaptors in BAM file
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $picard MarkIlluminaAdapters \
INPUT=$sample_dn/raw_unmapped_umi.bam \
OUTPUT=$sample_dn/raw_unmapped_markedAdpt.bam \
METRICS=$sample_dn/readstats/adapter_metrics.txt MAX_RECORDS_IN_RAM=1000000


