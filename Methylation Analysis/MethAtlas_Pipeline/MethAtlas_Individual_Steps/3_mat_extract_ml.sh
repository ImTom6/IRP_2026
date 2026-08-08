#!/usr/bin/bash
#SBATCH --job-name=3_MethAtlas_ExtractML
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=6:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Sorted and indexed patient bam from step 1
#Local installation of modkit (https://github.com/nanoporetech/modkit)
#hg38 reference FASTA

############################################

#Rename to file name
patient=

#Define local module pathways
modkit=/modkit_v0.6.4/./modkit

#Setting files/directories
in=/$patient
mkdir -p $in/results/methylation/
out_extract=$in/results/methylation

#Set location of hg38 reference FASTA
reference_genome=

file_name=${patient}_sorted.bam

# Execute the job code
$modkit pileup $in/$file_name $out_extract/${patient}.bedMethyl --ref $reference_genome --cpg --combine-strands --filter-threshold 0.75 --modified-bases 5mC --threads 8 --log-filepath $out_extract/${patient}.log
