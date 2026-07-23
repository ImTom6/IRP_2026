#!/usr/bin/bash
#SBATCH --job-name=4_uxm_bam2pat
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=18:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of wgbstools (https://github.com/nloyfer/wgbs_tools)
#Requires '$wgbstools init_genome hg38' run once to initialise the reference genome. Can be substituted for own reference with --fasta_path
#Cleaned .bam created in step 3

############################################

#Rename to file name
patient=

#Define local module pathways
wgbs_tools=/wgbs_tools/./wgbstools

#Setting files/directories
in=/$patient
mkdir -p $in/results/qc $in/results/methylation/
out=$in/results/methylation/

file_name=${patient}_cleaned.bam

###############################################

#Execute the job code

#Generate pat.gz files from .bam
$wgbs_tools bam2pat $in/$file_name --out_dir $out --genome hg38 --threads 2 --nanopore -f

