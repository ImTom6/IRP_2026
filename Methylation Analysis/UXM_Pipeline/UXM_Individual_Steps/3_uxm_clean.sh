#!/usr/bin/bash
#SBATCH --job-name=3_uxm_clean
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=14:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Samtools on HPC environment
#Sorted and indexed patient bam from step 1
#Local installation of modkit (https://github.com/nanoporetech/modkit)

############################################

#Rename to file name
patient=

#Load modules
module load samtools/1.17-wenuvv5

#Define local module pathways
modkit=/modkit_v0.6.4/./modkit

#Setting files/directories
in=/$patient
mkdir -p $in/results/methylation
out=$in/results/methylation

file_name=${patient}_sorted.bam

####################################################

#Execute the job code

#Adjusting modification tags to specifically only be cpg tags
$modkit adjust-mods $in/$file_name $out_clean/${patient}_cleaned.bam --cpg --threads 2

#Creating index of new .bam
samtools index $out_clean/${patient}_cleaned.bam

