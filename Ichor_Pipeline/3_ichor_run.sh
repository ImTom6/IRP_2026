#!/usr/bin/bash
#SBATCH --job-name=3_Ichor_Run
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of ichorCNA (https://github.com/broadinstitute/ichorCNA)
#.wig created in step 2

############################################

#Rename to file name
patient=

#Load Modules
module load R

#Setting files/directories
in_ichor=/${patient}/results/ichor
out_ichor=/${patient}/results/ichor

#######################################################

#Execute the job code
Rscript $ichor/scripts/runIchorCNA.R --id $patient \
  --WIG $in_ichor/${patient}.wig --ploidy "c(2,3)" --normal "c(0.5,0.6,0.7,0.8,0.9)" --maxCN 5 \
  --gcWig $ichor/inst/extdata/gc_hg38_1000kb.wig \
  --mapWig $ichor/inst/extdata/map_hg38_1000kb.wig \
  --centromere $ichor/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
  --normalPanel $ichor/inst/extdata/HD_ULP_PoN_hg38_1Mb_median_normAutosome_median.rds \
  --includeHOMD False --chrs "c(1:22, \"X\")" --chrTrain "c(1:22)" \
  --estimateNormal True --estimatePloidy True --estimateScPrevalence True \
  --scStates "c(1,3)" --txnE 0.9999 --txnStrength 10000 --outDir $out_ichor
