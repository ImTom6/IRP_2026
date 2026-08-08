#!/usr/bin/bash
#SBATCH --job-name=1_Ichor_Prep
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=16:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Samtools on HPC environment
#Patient .bam files
#If not already completed, requires a .txt file containing the list of bam files in the same directory
#Can be created with ls *.bam > /file_list.txt

############################################

#Rename to file name
patient=

#Load Modules
module load samtools/1.17-wenuvv5

#Setting files/directories
in_prep=/$patient
out_prep=/$patient

#######################################################

#Execute the job code

#Concatenate files together, no-PG to avoid @PG header lines
samtools cat --no-PG -b $in_prep/bam_pass/file_names.txt -o $out_prep/${patient}_cat.bam

#Sort the alignments by coordinates
samtools sort --no-PG -o $out_prep/${patient}_sorted.bam $in/${patient}_cat.bam

#Create corresponding index (.bai) file
samtools index $out/${patient}_sorted.bam
