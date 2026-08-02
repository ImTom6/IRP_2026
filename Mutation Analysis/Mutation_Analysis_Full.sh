#!/usr/bin/bash
#SBATCH --job-name=Avida_Mutation_Analysis_Full
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=14:00:00
#SBATCH --mem=32gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of fgbio (https://github.com/fulcrumgenomics/fgbio) [Version 1.5.1]
#Local installation of BWA (https://github.com/lh3/BWA) [Recommended v0.7.12-r1039 but v0.7.19-r1273 worked fine]
#Local installation of VarDictJava (https://github.com/AstraZeneca-NGS/VarDictJava) [Recommended v1.5.0, but v1.8.3 (Final Version) worked fine] 
#Local installation of snpEff and SnpSift (https://pcingola.github.io/SnpEff/) [Version 4.2]
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
VarDict=/Modules/VarDictJava/build/install/VarDict/bin/./VarDict
VarDict_Folder=/Modules/VarDictJava/VarDict
snpEff=/Modules/snpEff/./snpEff.jar
SnpSift=/Modules/snpEff/./SnpSift.jar
snpEff_Folder=/Modules/snpEff
picard=/Modules/picard.jar

#Set file path for reference genome
refs=/refs

#Set file path INCLUDING reference genome
reference_genome=$refs/genome.fa

#=====================================================================

#Prep (run once)

$bwa index $reference_genome

#Change output to name of genome(.dict)
java -jar $picard CreateSequenceDictionary R=$reference_genome O=$refs/genome.dict
java -jar $snpEff download hg38


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


############################################
#PART 2

#4. Convert BAM file to FASTQ file 
java -Xmx16G -jar $picard SamToFastq \
INPUT=$sample_dn/raw_unmapped_markedAdpt.bam \
FASTQ=$sample_dn/raw_unmapped_markedAdpt.fq \
MAX_RECORDS_IN_RAM=1000000 CLIPPING_MIN_LENGTH=36 \
INTERLEAVE=true INCLUDE_NON_PF_READS=true \
CLIPPING_ATTRIBUTE=XT CLIPPING_ACTION=X

#5. Align reads in FASTQ file to create SAM file
$bwa mem -p -t 10 \
$reference_genome \
$sample_dn/raw_unmapped_markedAdpt.fq > $sample_dn/raw_aligned.sam

#6. Merge data from unaligned and aligned BAM files
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $picard MergeBamAlignment \
UNMAPPED=$sample_dn/raw_unmapped_markedAdpt.bam \
ALIGNED=$sample_dn/raw_aligned.sam \
OUTPUT=$sample_dn/picard_fixed.bam \
REFERENCE_SEQUENCE=$reference_genome \
CLIP_ADAPTERS=false VALIDATION_STRINGENCY=SILENT \
CREATE_INDEX=true EXPECTED_ORIENTATIONS=FR MAX_GAPS=-1 \
SORT_ORDER=coordinate ALIGNER_PROPER_PAIR_FLAGS=false \
MAX_RECORDS_IN_RAM=1000000


#7. Group reads in BAM file by UMI
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio GroupReadsByUmi \
--input=$sample_dn/picard_fixed.bam \
--output=$sample_dn/grouped_umi.bam \
--strategy=paired --raw-tag=RX --assign-tag=MI --min-map-q=10 --edits=1

#8. Call consensus sequence for each set of UMI-grouped reads
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio CallMolecularConsensusReads \
--input=$sample_dn/grouped_umi.bam \
--output=$sample_dn/ss_consensus_unmapped.bam \
--rejects=$sample_dn/ss_rejects.bam \
--error-rate-pre-umi=45 --error-rate-post-umi=40 \
--min-input-base-quality=10 --min-reads=1

#9. Convert BAM file to FASTQ file
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $picard SamToFastq \
INPUT=$sample_dn/ss_consensus_unmapped.bam \
FASTQ=$sample_dn/ss_consensus_unmapped.fastq \
INTERLEAVE=true INCLUDE_NON_PF_READS=true MAX_RECORDS_IN_RAM=1000000

#10. Align UMI consensus reads in FASTQ file to create SAM file
$bwa mem -p -t 10 \
$reference_genome \
$sample_dn/ss_consensus_unmapped.fastq \
> $sample_dn/ss_consensus_mapped.sam

#11. Merge data from unaligned and aligned BAM files 
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $picard MergeBamAlignment \
UNMAPPED=$sample_dn/ss_consensus_unmapped.bam \
ALIGNED=$sample_dn/ss_consensus_mapped.sam \
OUTPUT=$sample_dn/ss_consensus_mapped.bam \
CLIP_ADAPTERS=false VALIDATION_STRINGENCY=SILENT \
CREATE_INDEX=true ORIENTATIONS=FR MAX_GAPS=-1 \
SORT_ORDER=coordinate ALIGNER_PROPER_PAIR_FLAGS=false \
ATTRIBUTES_TO_RETAIN=X ATTRIBUTES_TO_RETAIN=ZS \
ATTRIBUTES_TO_RETAIN=ZI ATTRIBUTES_TO_RETAIN=ZM \
ATTRIBUTES_TO_RETAIN=ZC ATTRIBUTES_TO_RETAIN=ZN \
ATTRIBUTES_TO_REVERSE=cd ATTRIBUTES_TO_REVERSE=ce \
REFERENCE_SEQUENCE=$reference_genome \
MAX_RECORDS_IN_RAM=1000000

#12. Filter merged reads in BAM file based on quality 
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio FilterConsensusReads \
--input=$sample_dn/ss_consensus_mapped.bam \
--output=$sample_dn/ss_consensus_filtered.bam \
--ref=$reference_genome \
--max-read-error-rate=0.05 --max-base-error-rate=0.1 \
--min-base-quality=10 --max-no-call-fraction=0.2 --min-reads=1 0 0

#13. Perform read clipping in BAM file to remove overlapping bases in R1 and R2 reads 
java -Djava.io.tmpdir=$sample_dn -Xmx24G -jar $fgbio ClipBam \
--input=$sample_dn/ss_consensus_filtered.bam \
--output=$sample_dn/ss_consensus_filtered_clipped.bam \
--ref=$reference_genome \
--clipping-mode=Hard --clip-overlapping-reads=true


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


############################################
#PART 4

#20. Perform variant calling for SNVs and indels
$VarDict -G $reference_genome \
-N $sid -b $sample_dn/ss_consensus_filtered_clipped.bam \
-f 0.001 -c 1 -S 2 -E 3 -g 4 -r 3 -F 0x700 -th 12 \
$refs/hglft_genome_2a8a03_875af0.bed | \
$VarDict_Folder/teststrandbias.R | \
$VarDict_Folder/var2vcf_valid.pl -N $sid -E -f 0.001 \
> $sample_dn/vd.vcf

#21. Annotate SNV and indel calls
#java -jar $SnpSift annotate \
#-dbsnp $sample_dn/vd_roi.vcf > $sample_dn/snpsift.vd.vcf

#java -jar $snpEff \
#-config $snpEff_Folder/snpEff.config \
#-noStats -noLog -nodownload hg38 \
#$sample_dn/snpsift.vd.vcf > $sample_dn/snpeff.vd.vcf

#Clean up unneeded files
rm $sample_dn/ds_consensus_filtered.bai
rm $sample_dn/ds_consensus_filtered.bam
rm $sample_dn/ds_consensus_mapped.bai
rm $sample_dn/ds_consensus_mapped.bam
rm $sample_dn/ds_consensus_mapped.sam
rm $sample_dn/ds_consensus_unmapped.bam
rm $sample_dn/ds_consensus_unmapped.fastq
rm $sample_dn/grouped_umi.bam
rm $sample_dn/picard_fixed.bai
rm $sample_dn/picard_fixed.bam
rm $sample_dn/raw_aligned.sam
rm $sample_dn/raw_unmapped.bam
rm $sample_dn/raw_unmapped_markedAdpt.bam
rm $sample_dn/raw_unmapped_markedAdpt.fq
rm $sample_dn/raw_unmapped_umi.bam
rm $sample_dn/ss_consensus_filtered.bai
rm $sample_dn/ss_consensus_filtered.bam
rm $sample_dn/ss_consensus_filtered_clipped.bai
rm $sample_dn/ss_consensus_filtered_clipped.bam
rm $sample_dn/ss_consensus_mapped.bai
rm $sample_dn/ss_consensus_mapped.bam
rm $sample_dn/ss_consensus_mapped.sam
rm $sample_dn/ss_consensus_unmapped.bam
rm $sample_dn/ss_consensus_unmapped.fastq
rm $sample_dn/ss_rejects.bam
