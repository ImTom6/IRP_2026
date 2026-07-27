#!/usr/bin/bash
#SBATCH --job-name=5_uxm_deconvolve
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=4:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of UXM_deconv (https://github.com/nloyfer/UXM_deconv)
#pat.gz created in step 4

############################################

#Rename to file name
patient=

#Define local module pathways
uxm=/UXM_deconv/./uxm

#Set atlas location within uxm module
atlas_location=/UXM_deconv/supplemental/Atlas.U25.l4.hg38.tsv

#Setting files/directories
in=/$patient
mkdir -p $in/results/qc $in/results/methylation/ $in/results/deconvolution
in_deconv=$in/results/methylation
out_deconv=$in/results/deconvolution

file_name=${patient}_sorted.bam

#####################################################################

# Execute the job code

#Complete uxm deconvolution on pat.gz twice, once as normal, and once with blood cells removed to improve readability of output
$uxm deconv --atlas $atlas_location $in_deconv/${patient}_cleaned.pat.gz --output $out_deconv/${patient}.uxm.csv
$uxm deconv --atlas $atlas_location $in_deconv/${patient}_cleaned.pat.gz --ignore Blood-B Blood-Granul Blood-Mono+Macro Blood-T Blood-NK Eryth-prog Megakaryocytes --output $out_deconv/${patient}_ignoreblood.uxm.csv
