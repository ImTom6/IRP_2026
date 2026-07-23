#!/usr/bin/bash
#SBATCH --job-name=6_MethAtlas_Map
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=06:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Converted .bedMethyl created from step 5
#Htslib on HPC environment
#Bedtools on HPC environment
#Requires 450k manifest
#Requires hg38.genome

############################################

#Rename to file name
patient=

#Load modules
module load htslib/1.17-xwll33g  
module load bedtools2/2.31.0-nedc4o7

#Setting files/directories
in=/$patient
mkdir -p $in/results/deconvolution/
in_map=$in/results/deconvolution
out_map=$in/results/deconvolution

#Set location of general reference folder for more references to be placed here
refs=/refs

##################################################################

# Execute the job code

#Slop manifest (Only needs to run once)
bedtools slop -i $refs/manifest450k.bed4 -r 1 -l 0 -g $refs/hg38.genome > $refs/manifest_slopped.bed

#Intersect bedGraph with slopped manifest
bedtools intersect -a $refs/manifest_slopped.bed -b $in_map/${patient}.converted.bedGraph -wa -wb > $out_map/${patient}_converted_mapped_450k.bed
