 #!/usr/bin/env python

#-------------------------------UMI module----------------#
_umi_threads=16

configfile: "umi_config.yaml"


def umi_individual_targets(wildcards):
    """Generates the targets for this module"""
    ls = []
    for sample in config["samples"]:
        ls.append("analysis/umi/%s/%s.dedupped.grouped.bam" % (sample,sample))
        ls.append("analysis/umi/%s/%s.grouped.tsv" % (sample,sample))
    return ls

rule umi_individual_all:
    input:
        umi_individual_targets


def align_getBam(wildcards):
    ##bams with duplicates marked with ‘RX’ tag and bai index
    bam = config["samples"][wildcards.sample][0] #returns only the first elm
    return bam


###------------------UMI-tools individual rules----------------------##
rule umi_extract:
     input:
        align_getBam
     output:
         grouped_tsv = "analysis/umi/{sample}/{sample}.grouped.tsv",
         bam = "analysis/umi/{sample}/{sample}.dedupped.grouped.bam" ##bam with duplicate reads removed can later be used for bam2fastq
     threads: _umi_threads
     message: "Running UMI-tools on {wildcards.sample}"
     log:
         "logs/umi/{sample}.umi.log"
     params:
         sampleID = lambda wildcards: [wildcards.sample],
         outpath = "analysis/umi/{sample}/",
         path = "set +eu;source activate %s" % config['umi_root'],
     shell:
          """{params.path};umi_tools group -I {input}  --group-out={output.grouped_tsv} --output-bam   --paired -S {output.bam} --umi-tag=RX --extract-umi-method=tag """
