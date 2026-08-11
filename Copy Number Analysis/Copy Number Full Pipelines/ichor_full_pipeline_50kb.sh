#!/usr/bin/bash
#SBATCH --job-name=ichor_pipeline_full_50kb
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=04:00:00
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

mkdir -p $in/results/ichor -p $in/results/ichor/50k

#=====================================================================

# Directories for each step
#1. Prep

#2. Ichor Prep
in_util=/${patient}
out_util=/${patient}/results/ichor/50k

#3. Run Ichor
in_ichor=/${patient}/results/ichor/50k
out_ichor=/${patient}/results/ichor/50k


##############################################

# Execute the job code

#1. Prep
samtools cat --no-PG -b $in/bam_pass/file_names.txt -o $in/${patient}_cat.bam
samtools sort --no-PG -o $in/${patient}_sorted.bam $in/${patient}_cat.bam
samtools index $in/${patient}_sorted.bam

file_name=${patient}_sorted.bam


#2. Ichor Prep
$hmm_util/readCounter --window 50000 \
--quality 20 \
--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY" $in_util/$file_name > $out_util/${patient}_50kb.wig

#3. Run Ichor
Rscript $ichor/scripts/runIchorCNA.R --id $patient \
  --WIG $in_ichor/${patient}_50kb.wig --ploidy "c(2)" --normal "c(0.95, 0.99, 0.995, 0.999)" --maxCN 5 \
  --gcWig $ichor/inst/extdata/gc_hg38_50kb.wig \
  --mapWig $ichor/inst/extdata/map_hg38_50kb.wig \
  --centromere $ichor/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \ 
  --normalPanel $refs/ \ #Baseline used. If unavailable, use pre built baseline instead.
  --includeHOMD False --chrs "c(1:22)" --chrTrain "c(1:22)" \
  --estimateScPrevalence False \
  --estimateNormal True --estimatePloidy True \
  --txnE 0.999999 --txnStrength 10000 --outDir $out_ichor
  
#4. Clean up files
rm $in/${patient}_cat.bam
rm $in_ichor/${patient}.wig
