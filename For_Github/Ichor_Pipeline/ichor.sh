#!/usr/bin/bash
#SBATCH --job-name=ichor_pipeline
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=16:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of hmmcopy_utils (https://github.com/shahcompbio/hmmcopy_utils)
#Local installation of ichorCNA (https://github.com/broadinstitute/ichorCNA)
#Samtools on HPC environment
#Patient .bam files
#If not already completed, requires a .txt file containing the list of bam files in the same directory
#Can be created with ls *.bam > /file_list.txt
#R on HPC

############################################

#NAME OF DIRECTORY (Change name)
patient=

#Load modules
module load R

#Load local modules
hmm_util=/hmmcopy_utils/bin
ichor=/ichorCNA

in=/${patient}

mkdir -p $in/results/ichor

#=====================================================================

# Directories for each step
#1. Prep

#2. Ichor Prep
in_util=/${patient}
out_util=/${patient}/results/ichor

#3. Run Ichor
in_ichor=/${patient}/results/ichor
out_ichor=/${patient}/results/ichor


##############################################

# Execute the job code

#1. Prep
samtools cat --no-PG -b $in/bam_pass/file_names.txt -o $in/${patient}_cat.bam
samtools sort --no-PG -o $in/${patient}_sorted.bam $in/${patient}_cat.bam
samtools index $in/${patient}_sorted.bam

file_name=${patient}_sorted.bam


#2. Ichor Prep
$hmm_util/readCounter --window 1000000 --quality 20 --chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY" $in_util/$file_name > $out_util/${patient}.wig


#3. Run Ichor
Rscript $ichor/scripts/runIchorCNA.R --id $patient \
  --WIG $in_ichor/${patient}.wig --ploidy "c(2,3)" --normal "c(0.5,0.6,0.7,0.8,0.9)" --maxCN 5 \
  --gcWig $ichor/inst/extdata/gc_hg38_1000kb.wig \
  --mapWig $ichor/inst/extdata/map_hg38_1000kb.wig \
  --centromere $ichor/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
  --normalPanel $ichor/inst/extdata/HD_ULP_PoN_hg38_1Mb_median_normAutosome_median.rds \
  --includeHOMD False --chrs "c(1:22, \"X\")" --chrTrain "c(1:22)" \
  --estimateNormal True --estimatePloidy True --estimateScPrevalence True \
  --scStates "c(1,3)" --txnE 0.9999 --txnStrength 10000 --outDir $out_ichor
