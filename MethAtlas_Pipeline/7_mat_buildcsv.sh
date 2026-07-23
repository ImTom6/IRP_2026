#!/usr/bin/bash
#SBATCH --job-name=7_MethAtlas_Buildcsv
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Mapped .bed from step 6

############################################

#Rename to file name
patient=

#Setting files/directories
in=/$patient
mkdir -p $in/results/deconvolution/
in_build=$in/results/deconvolution
out_build=$in/results/deconvolution

#Set location of general reference folder for more references to be placed here
refs=/refs

##################################################################

# Execute the job code
#Extract methylation and illumina ids from .bed
{ echo ",${patient}"; awk 'BEGIN{OFS=","} {print $4, $8}' $in_build/${patient}_converted_mapped_450k.bed; } > $out_build/${patient}_build.csv
