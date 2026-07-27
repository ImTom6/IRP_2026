


**Input:**
Requires all .bam files inside a directory along with a .txt listing the pathways for all files.

**Outputs:**
Outputs stacked bar chart estimating the proportions of different tissue types, along with a .csv that can be used to produce your own graphs. 

**Requirements:**

- Local installation of modkit (https://github.com/nanoporetech/modkit)
- Local installation of methatlas (https://github.com/nloyfer/meth_atlas)
- Samtools on HPC environment
- Htslib on HPC environment
- Bedtools on HPC environment
- Patient .bam files
- If not already completed, requires a .txt file containing the list of bam files in the same directory
- Can be created with ls *.bam > /file_list.txt
- hg38 reference FASTA
- Requires 450k manifest
- Requires hg38.genome
- Python3 on HPC
