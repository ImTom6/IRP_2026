#!/usr/bin/bash
#SBATCH --job-name=6_uxm_plots
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=2:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of UXM_deconv (https://github.com/nloyfer/UXM_deconv)
#.csvs created in step 5

############################################

#Rename to file name
patient=

#Define local module pathways
uxm=/UXM_deconv/./uxm

#Setting files/directories
in=/$patient
mkdir -p $in/results/deconvolution $in/results/plots
in_plots=$in/results/deconvolution
out_plots=$in/results/plots

########################################################

#Execute the job code

#Plot outputs for csvs with and without blood cells
$uxm plot $in_plots/${patient}.uxm.csv --outpath $out_plots/${patient}_plot.pdf
$uxm plot $in_plots/${patient}_ignoreblood.uxm.csv --outpath $out_plots/${patient}_ignoreblood_plot.pdf



