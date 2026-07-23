#!/usr/bin/bash
#SBATCH --job-name=ONT_Full_UXM_Pipeline
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=26:00:00
#SBATCH --mem=24gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of modkit (https://github.com/nanoporetech/modkit)
#Local installation of wgbstools (https://github.com/nloyfer/wgbs_tools)
#Local installation of UXM_deconv (https://github.com/nloyfer/UXM_deconv)
#Samtools on HPC environment
#Patient .bam files
#If not already completed, requires a .txt file containing the list of bam files in the same directory
#Can be created with ls *.bam > /file_list.txt

############################################

#NAME OF DIRECTORY (Change name)
patient=

#Load modules
module load samtools/1.17-wenuvv5

#Load local modules (Adjust paths to work correctly)
modkit=/modkit_v0.6.4/./modkit
wgbs_tools=/wgbs_tools/./wgbstools
uxm=/UXM_deconv/./uxm

#Set reference locations
atlas_location=$uxm/UXM_deconv/supplemental/Atlas.U25.l4.hg38.tsv

# Make file directories
in=/$patient
mkdir -p $in/results/qc $in/results/methylation/ $in/results/deconvolution $in/results/plots

#=====================================================================

# Directories for each step
#1. Prep

#2. QC
out_qc=$in/results/qc

#3. Clean
out_clean=$in/results/methylation/

#4. BAM2PAT
file_cleaned=${patient}_cleaned.bam
in_BAM2PAT=$in/results/methylation
out_BAM2PAT=$in/results/methylation

#5. Deconvolution
in_deconv=$in/results/methylation
out_deconv=$in/results/deconvolution

#6. Plots
in_plots=$in/results/deconvolution
out_plots=$in/results/plots

#=====================================================================

# Execute the job code

#1. Prep

#Concatenate files together, no-PG to avoid @PG header lines
samtools cat --no-PG -b $in/bam_pass/file_names.txt -o $in/${patient}_cat.bam

#Sort the alignments by coordinates
samtools sort --no-PG -o $in/${patient}_sorted.bam $in/${patient}_cat.bam

#Create corresponding index (.bai) file
samtools index $in/${patient}_sorted.bam

#Set new file name
file_name=${patient}_sorted.bam


#2. QC

#Providing the user with a range of qc stats in the /qc directory
samtools flagstat $in/$file_name > $out_qc/${patient}_flagstat.txt
samtools stats $in/$file_name > $in/results/qc/stats.txt
$modkit summary $in/$file_name > $out_qc/${patient}_summary.txt


#3. Clean

#Adjusting modification tags to specifically only be cpg tags
$modkit adjust-mods $in/$file_name $out_clean/${patient}_cleaned.bam --cpg --threads 2

#Creating index of new .bam
samtools index $out_clean/${patient}_cleaned.bam


#4. BAM2PAT

#Generate pat.gz files from .bam
$wgbs_tools bam2pat $in_BAM2PAT/$file_cleaned --out_dir $out_BAM2PAT --genome hg38 --threads 2 --nanopore -f


#5. Deconvolution 

#Complete uxm deconvolution on pat.gz twice, once as normal, and once with blood cells removed to improve readability of output
$uxm deconv --atlas $atlas_location $in_deconv/${patient}_cleaned.pat.gz --output $out_deconv/${patient}.uxm.csv
$uxm deconv --atlas $atlas_location $in_deconv/${patient}_cleaned.pat.gz --ignore Blood-B Blood-Granul Blood-Mono+Macro Blood-T Blood-NK Eryth-prog Megakaryocytes --output $out_deconv/${patient}_ignoreblood.uxm.csv

#6. Plots

#Plot outputs for csvs with and without blood cells
$uxm plot $in_plots/${patient}.uxm.csv --outpath $out_plots/${patient}_plot.pdf
$uxm plot $in_plots/${patient}_ignoreblood.uxm.csv --outpath $out_plots/${patient}_ignoreblood_plot.pdf
