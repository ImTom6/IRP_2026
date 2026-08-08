**UXM_Deconv Pipeline**

**Input:**
Requires all .bam files inside a directory along with a .txt listing the pathways for all files.

**Outputs:**
Outputs stacked bar chart estimating the proportions of different tissue types, along with a .csv that can be combined with other .csvs in Plot_UXM.R to produce one graph comparing all samples.

**Requirements:**

- Local installation of modkit (https://github.com/nanoporetech/modkit)
- Local installation of wgbstools (https://github.com/nloyfer/wgbs_tools)
- Local installation of UXM_deconv (https://github.com/nloyfer/UXM_deconv)
- Samtools on HPC environment
- Patient .bam files
- If not already completed, requires a .txt file containing the list of bam files in the same directory
- Can be created with ls *.bam > /file_list.txt

The pipeline can be run in full, or individual steps can be run (Found in UXM_Individual_Steps directory)

Caution:
All code has been sanitized prior to uploading. Therefore, do not expect any code to run _as is_. You will need to alter directory pathways and file names where necessary. The pipelines have been designed in a way that places all of this information near the top, making it as easy as possible to get up and running.

**References:**

Danecek, P. et al. (2021) 'Twelve years of SAMtools and BCFtools', GigaScience, 10(2), pp. giab008. doi: 10.1093/gigascience/giab008. Available at: https://doi.org/10.1093/gigascience/giab008 .

Loyfer, N. et al. (2023) 'A DNA methylation atlas of normal human cell types', Nature, 613(7943), pp. 355–364. Available at: https://doi.org/10.1038/s41586-022-05580-6 .

Loyfer, N., Rosenski, J. and Kaplan, T. (2026) 'Wgbstools: A computational suite for DNA methylation sequencing data analysis', Life Science Alliance, 9(4), pp. e202503514. doi: 10.26508/lsa.202503514. Print 2026 Apr. Available at: https://doi.org/10.26508/lsa.202503514 .

Oxford Nanopore Technologies. (2026) Modkit Available at: https://github.com/nanoporetech/modkit (Downloaded: 15 June 2026).


This research used the ALICE High Performance Computing facility at the University of Leicester.
