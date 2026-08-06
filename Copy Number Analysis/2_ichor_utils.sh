#!/usr/bin/bash
#SBATCH --job-name=2_Ichor_utils
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of hmmcopy_utils (https://github.com/shahcompbio/hmmcopy_utils)
#Sorted and indexed .bam from step 1

############################################

#Rename to file name
patient=

#Load Modules
module load R

#Setting files/directories
in_util=/${patient}
out_util=/${patient}/results/ichor

#######################################################

#Execute the job code
$hmm_util/readCounter --window 50000 \
--quality 20 \
--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY" $in_util/$file_name > $out_util/${patient}_50kb.wig
