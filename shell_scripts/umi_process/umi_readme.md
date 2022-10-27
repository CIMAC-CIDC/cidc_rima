#----------------UMI processing folder-----------#
This folder contains the setup files to convert the UMI BAM (Received from Broad) to dedupped BAM, which can be further used with the automator input to run the RIMA pipeline.
The script uses UMI-tools(https://umi-tools.readthedocs.io/en/latest/index.html) to process the sample and this tool can be installed easily using pip or conda.

Pre-requirements: snakemake tool is required to run this code , which can be found in the RIMA image("rima-ver3-1")

There are two files included in this folder.
(1) umi_config.yaml: This example file is the input to the umi.snakefile and needs to be prepared first. The sample name and sample path can be added in the file as below.
SAMPLE:
  SAMPLENAME:
    - path to the SAMPLE

(2) umi.snakefile: This file takes the input file defined in the config file , runs the UMI-tools and outputs the dedupped BAM file. This dedupped BAM file can be used with the automator input.


This file can be run as follows:
  """snakemake -s umi.snakefile  -j 64 """  



Please follow the automator documentation once the dedupped BAM are obtained.
