


**Input:**
Both pipelines require all .bam files inside a directory along with a .txt listing the pathways for all files.

**Outputs:**
Both pipelines output stacked bar charts estimating the proportions of different tissue types, along with a .csv that can be used to produce your own graphs. 

**Requirements:**

- Local installation of modkit (https://github.com/nanoporetech/modkit)
- Local installation of wgbstools (https://github.com/nloyfer/wgbs_tools)
- Local installation of UXM_deconv (https://github.com/nloyfer/UXM_deconv)
- Samtools on HPC environment 
- Patient .bam files
- If not already completed, requires a .txt file containing the list of bam files in the same directory
- Can be created with ls *.bam > /file_list.txt
