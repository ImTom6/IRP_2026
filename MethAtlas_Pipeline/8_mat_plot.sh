#!/usr/bin/bash
#SBATCH --job-name=8_MethAtlas_Plot
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=16gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of methatlas (https://github.com/nloyfer/meth_atlas)
#Python 3 on HPC
#csv produced in step 7

############################################

#Rename to file name
patient=

#Load local modules
meth_atlas=/meth_atlas/deconvolve.py

#Setting files/directories
in=/$patient
mkdir -p $in/results/deconvolution/ $in/results/plots
in_atlas=$in/results/deconvolution
out_atlas=$in/results/plots

#Set location of meth atlas reference atlas (Found within meth_atlas directory)
atlas_loc=/meth_atlas/reference_atlas.csv

##################################################################

# Execute the job code
#Plot graph from csv
python3 $meth_atlas --atlas_path $atlas_loc $in_atlas/${patient}_build.csv --out_dir $out_atlas
