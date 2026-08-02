#!/usr/bin/bash
#SBATCH --job-name=Avida_Mutation_Analysis_Full
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=04:00:00
#SBATCH --mem=32gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of fgbio (https://github.com/fulcrumgenomics/fgbio) [Version 1.5.1]
#Local installation of BWA (https://github.com/lh3/BWA) [Recommended v0.7.12-r1039 but v0.7.19-r1273 worked fine]
#Local installation of picard (https://github.com/broadinstitute/picard) [Version 2.20.1]
#hg38 reference genome
#R on HPC [Recommended v3.5.1 but v4.3.1 worked fine]
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
bwa=/Modules/bwa/bwa
picard=/Modules/picard.jar

#Set file path for reference genome
refs=/refs

#Set file path INCLUDING reference genome
reference_genome=$refs/genome.fa

############################################

#PART 3

#14. Call duplex consensus
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio CallDuplexConsensusReads \
--input=$sample_dn/grouped_umi.bam \
--output=$sample_dn/ds_consensus_unmapped.bam \
--error-rate-pre-umi=45 --error-rate-post-umi=40 --min-input-base-quality=10

#15. Convert BAM file to FASTQ file
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $picard SamToFastq \
INPUT=$sample_dn/ds_consensus_unmapped.bam \
FASTQ=$sample_dn/ds_consensus_unmapped.fastq \
INTERLEAVE=true INCLUDE_NON_PF_READS=true \
MAX_RECORDS_IN_RAM=1000000

#16. Align UMI consensus reads to create SAM file
$bwa mem -p -t 10 $reference_genome \
$sample_dn/ds_consensus_unmapped.fastq > $sample_dn/ds_consensus_mapped.sam

#17. Merge data from unaligned and aligned BAM files
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $picard MergeBamAlignment \
UNMAPPED=$sample_dn/ds_consensus_unmapped.bam \
ALIGNED=$sample_dn/ds_consensus_mapped.sam \
OUTPUT=$sample_dn/ds_consensus_mapped.bam \
CLIP_ADAPTERS=false VALIDATION_STRINGENCY=SILENT \
CREATE_INDEX=true ORIENTATIONS=FR MAX_GAPS=-1 \
SORT_ORDER=coordinate ALIGNER_PROPER_PAIR_FLAGS=false \
ATTRIBUTES_TO_RETAIN=X0 ATTRIBUTES_TO_RETAIN=ZS \
ATTRIBUTES_TO_RETAIN=ZI ATTRIBUTES_TO_RETAIN=ZM \
ATTRIBUTES_TO_RETAIN=ZC ATTRIBUTES_TO_RETAIN=ZN \
ATTRIBUTES_TO_REVERSE=cd ATTRIBUTES_TO_REVERSE=ce \
REFERENCE_SEQUENCE=$reference_genome \
MAX_RECORDS_IN_RAM=1000000

#18. Filter merged reads in BAM file based on quality
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio FilterConsensusReads \
--input=$sample_dn/ds_consensus_mapped.bam \
--output=$sample_dn/ds_consensus_filtered.bam \
--ref=$reference_genome \
--max-read-error-rate=0.2 --max-base-error-rate=0.4 \
--min-base-quality=30 --max-no-call-fraction=0.4 --min-reads=2 1 1

#19. Perform read clipping in BAM file to remove overlapping bases in R1 and R2 reads
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio ClipBam \
--input=$sample_dn/ds_consensus_filtered.bam \
--output=$sample_dn/ds_consensus_filtered_clipped.bam \
--ref=$reference_genome \
--clipping-mode=Hard --clip-overlapping-reads=true
