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
#3. Run Ichor
Rscript $ichor/scripts/runIchorCNA.R --id $patient \
  --WIG $in_ichor/${patient}_50kb.wig --ploidy "c(2)" --normal "c(0.95, 0.99, 0.995, 0.999)" --maxCN 5 \
  --gcWig $ichor/inst/extdata/gc_hg38_50kb.wig \
  --mapWig $ichor/inst/extdata/map_hg38_50kb.wig \
  --centromere $ichor/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
  --includeHOMD False --chrs "c(1:22)" --chrTrain "c(1:22)" \
  --estimateScPrevalence False \
  --estimateNormal True --estimatePloidy True \
  --txnE 0.999999 --txnStrength 10000 --outDir $out_ichor
