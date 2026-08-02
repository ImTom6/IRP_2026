#!/usr/bin/bash
#SBATCH --job-name=Avida_Mutation_Analysis_Full
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=02:00:00
#SBATCH --mem=32gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of VarDictJava (https://github.com/AstraZeneca-NGS/VarDictJava) [Recommended v1.5.0, but v1.8.3 (Final Version) worked fine] 
#Local installation of snpEff and SnpSift (https://pcingola.github.io/SnpEff/) [Version 4.2]
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
VarDict=/Modules/VarDictJava/build/install/VarDict/bin/./VarDict
VarDict_Folder=/Modules/VarDictJava/VarDict
snpEff=/Modules/snpEff/./snpEff.jar
SnpSift=/Modules/snpEff/./SnpSift.jar
snpEff_Folder=/Modules/snpEff

#Set file path for reference genome
refs=/refs

#Set file path INCLUDING reference genome
reference_genome=$refs/genome.fa

#=====================================================================

# Run once
java -jar $snpEff download hg38

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

