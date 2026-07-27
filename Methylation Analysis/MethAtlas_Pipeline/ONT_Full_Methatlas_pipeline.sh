#!/usr/bin/bash
#SBATCH --job-name=ONT_Full_Methatlas_pipeline
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=48:00:00
#SBATCH --mem=24gb
#SBATCH --export=NONE

############################################
#REQUIREMENTS
#Local installation of modkit (https://github.com/nanoporetech/modkit)
#Local installation of methatlas (https://github.com/nloyfer/meth_atlas)
#Samtools on HPC environment
#Htslib on HPC environment
#Bedtools on HPC environment
#Patient .bam files
#If not already completed, requires a .txt file containing the list of bam files in the same directory
#Can be created with ls *.bam > /file_list.txt
#hg38 reference FASTA
#Requires 450k manifest
#Requires hg38.genome
#Python3 on HPC

############################################

#NAME OF DIRECTORY (Change name)
patient=

#Load modules
module load samtools/1.17-wenuvv5
module load htslib/1.17-xwll33g  
module load bedtools2/2.31.0-nedc4o7

#Load local modules
modkit=/modkit_v0.6.4/./modkit
meth_atlas=/meth_atlas/deconvolve.py

#Set reference locations
#Set location of hg38 reference FASTA
reference_genome=
#Set location of general reference folder for more references to be placed here
refs=/refs
#Set location of meth atlas reference atlas (Found within meth_atlas directory)
atlas_loc=/meth_atlas/reference_atlas.csv

# Make file directories
in=/$patient
mkdir -p $in/results/qc $in/results/methylation $in/results/deconvolution $in/results/plots



#=====================================================================

# Directories for each step
#1. Prep

#2. QC
out_qc=$in/results/qc

#3. Extract ML
out_extract=$in/results/methylation

#4. Filter
in_filter=$in/results/methylation
out_filter=$in/results/methylation

#5. Convert to bedGraph
in_convert=$in/results/methylation
out_convert=$in/results/deconvolution

#6. Map to manifest
in_map=$in/results/deconvolution
out_map=$in/results/deconvolution

#7. Build input csv
in_build=$in/results/deconvolution
out_build=$in/results/deconvolution

#8. Plot
in_atlas=$in/results/deconvolution
out_atlas=$in/results/plots
#=====================================================================

# Execute 
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
samtools stats $in/$file_name > $out_qc/${patient}_stats.txt
$modkit summary $in/$file_name > $out_qc/${patient}_summary.txt

#3. Extract ML
$modkit pileup $in/$file_name $out_extract/${patient}.bedMethyl --ref $reference_genome --cpg --combine-strands --filter-threshold 0.75 --modified-bases 5mC --threads 8 --log-filepath $out_extract/${patient}.log


#4. Filter

#Filter out poor quality reads
awk '$10 >= 5' $in_filter/${patient}.bedMethyl > $out_filter/${patient}.filtered.bedMethyl


#5. Convert to bedGraph (and converting column 11 to a fraction)
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $11/100}' $in_convert/${patient}.filtered.bedMethyl > $out_convert/${patient}.converted.bedGraph


#6. Map to manifest
bedtools slop -i $refs/manifest450k.bed4 -r 1 -l 0 -g $refs/hg38.genome > $refs/manifest_slopped.bed
bedtools intersect -a $refs/manifest_slopped.bed -b $in_map/${patient}.converted.bedGraph -wa -wb > $out_map/${patient}_converted_mapped_450k.bed


#7. Build input csv
#Extract methylation and illumina ids from .bed
{ echo ",${patient}"; awk 'BEGIN{OFS=","} {print $4, $8}' $in_build/${patient}_converted_mapped_450k.bed; } > $out_build/${patient}_build.csv


#8. Plot
#Plot graph from csv
python3 $meth_atlas --atlas_path $atlas_loc $in_atlas/${patient}_build.csv --out_dir $out_atlas


#9. Remove intermediate files
rm $in/${patient}_cat.bam
rm $out_extract/${patient}.bedMethyl
rm $out_filter/${patient}.filtered.bedMethyl
rm $out_convert/${patient}.sample.bedGraph
rm $out_map/${patient}_sample_mapped_450k.bed
