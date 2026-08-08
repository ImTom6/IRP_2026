**MethAtlas Pipeline**


**Input:**
Requires all .bam files inside a directory along with a .txt listing the pathways for all files.

**Outputs:**
Outputs stacked bar chart estimating the proportions of different tissue types, along with a .csv that can be combined with other .csvs in Plot_MethAtlas.R to produce one graph comparing all samples. 

**Requirements:**

- Local installation of modkit (https://github.com/nanoporetech/modkit)
- Local installation of methatlas (https://github.com/nloyfer/meth_atlas)
- Samtools on HPC environment
- Bedtools on HPC environment
- Patient .bam files
- If not already completed, requires a .txt file containing the list of bam files in the same directory
- Can be created with ls *.bam > /file_list.txt
- hg38 reference FASTA
- Requires 450k manifest
- Requires hg38.genome
- Python3 on HPC


The pipeline can be run in full, or individual steps can be run (Found in MethAtlas_Individual_Steps directory)

Caution:
All code has been sanitized prior to uploading. Therefore, do not expect any code to run _as is_. You will need to alter directory pathways and file names where necessary. The pipelines have been designed in a way that places all of this information near the top, making it as easy as possible to get up and running.

**References:**

Danecek, P. et al. (2021) 'Twelve years of SAMtools and BCFtools', GigaScience, 10(2), pp. giab008. doi: 10.1093/gigascience/giab008. Available at: https://doi.org/10.1093/gigascience/giab008 .

Lai D, Ha G and Shah S. (2026) HMMcopy: Copy number prediction with correction for GC and mappability bias for HTS data.Available at: https://bioconductor.org/packages/HMMcopy (Downloaded: 15 July 2026).

Moss, J. et al. (2018) 'Comprehensive human cell-type methylation atlas reveals origins of circulating cell-free DNA in health and disease', Nature Communications, 9(1), pp. 5068–6. Available at: https://doi.org/10.1038/s41467-018-07466-6 .

Oxford Nanopore Technologies. (2026) Modkit Available at: https://github.com/nanoporetech/modkit (Downloaded: 15 June 2026).

Quinlan, A.R. and Hall, I.M. (2010) 'BEDTools: A flexible suite of utilities for comparing genomic features', Bioinformatics (Oxford, England), 26(6), pp. 841–842. Available at: https://doi.org/10.1093/bioinformatics/btq033 .

This research used the ALICE High Performance Computing facility at the University of Leicester.
