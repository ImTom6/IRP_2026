#!/usr/bin/bash
#SBATCH --job-name=5_MethAtlas_Convert
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Filtered .bedMethyl created from step 4

############################################

#Rename to file name
patient=

#Setting files/directories
in=/$patient
mkdir -p $in/results/methylation/
in_convert=$in/results/methylation
out_convert=$in/results/deconvolution

##################################################################

# Execute the job code

#Convert to bedGraph (and converting column 11 to a fraction)
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $11/100}' $in_convert/${patient}.filtered.bedMethyl > $out_convert/${patient}.converted.bedGraph
