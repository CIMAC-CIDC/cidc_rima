#!/usr/bin/env python

#-------------------------------immune response indiviudal run-------------------------#
#----------------------------MSIsensor2--------------------#

def immune_response_individual_targets(wildcards):
    ls=[]
    for sample in config["samples"]:
            ls.append("analysis/msisensor/single/%s/%s_msisensor" % (sample, sample))
            ls.append("analysis/msisensor/single/%s/%s_msisensor_dis" % (sample, sample))
            ls.append("analysis/msisensor/single/%s/%s_msisensor_somatic" % (sample, sample))
    return ls


rule immune_response_individual_all:
    input:
        immune_response_individual_targets


rule msisensor_tumor_call:
    input:
        bam = "analysis/star/{sample}/{sample}.sorted.bam",
        bai = "analysis/star/{sample}/{sample}.sorted.bam.bai"
    output:
        "analysis/msisensor/single/{sample}/{sample}_msisensor",
        "analysis/msisensor/single/{sample}/{sample}_msisensor_dis",
        "analysis/msisensor/single/{sample}/{sample}_msisensor_somatic"
    message:
        "Running msisensor on {wildcards.sample}"
    benchmark:
        "benchmarks/msisensor/single/{sample}.msisensor.benchmark"
    log:
        "logs/msisensor/single/{sample}.msisensor.log"
    params:
        prefix = "analysis/msisensor/single/{sample}/{sample}_msisensor",
        msisensor2_path= config["msisensor2_path"],
    shell:
        "{params.msisensor2_path}/msisensor2 msi -M {params.msisensor2_path}/models_hg38 -t {input[0]} -o {params.prefix}"
