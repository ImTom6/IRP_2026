#!/usr/bin/bash
#SBATCH --job-name=4_MethAtlas_Filter
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#.bedMethyl created from step 3

############################################

#Rename to file name
patient=

#Setting files/directories
in=/$patient
mkdir -p $in/results/methylation/
in_filter=$in/results/methylation
out_filter=$in/results/methylation

##################################################################

# Execute the job code

#Filter out poor quality reads
awk '$10 >= 5' $in_filter/${patient}.bedMethyl > $out_filter/${patient}.filtered.bedMethyl
