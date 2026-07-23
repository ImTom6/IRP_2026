#!/usr/bin/bash
#SBATCH --job-name=2_MethAtlas_QC
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=2:00:00
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
mkdir -p $in/results/qc
out=$in/results/qc
file_name=${patient}_sorted.bam

##################################################

#Execute the job code

#Providing the user with a range of qc stats in the /qc directory
samtools flagstat $in/$file_name > $out/${patient}_flagstat.txt
samtools stats $in/$file_name > $in/results/qc/stats.txt
$modkit summary $in/$file_name > $out/${patient}_summary.txt
