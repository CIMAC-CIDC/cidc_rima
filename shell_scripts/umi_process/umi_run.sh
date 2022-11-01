#!/bin/bash

#----Activate the environment----#
export CONDA_ROOT=/home/aashna/miniconda3
export PATH=/home/aashna/miniconda3/bin:$PATH
source activate rnaseq_new

snakemake -s umi.snakefile -j 64 -k 
