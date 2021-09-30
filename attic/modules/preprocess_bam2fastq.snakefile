configfile: "config.yaml"

def bam2fastq_targets(wildcards):
    ls = []
    for sample in config['samples']:
        ls.append("data/%s/%s_1.fq.gz" % (sample,sample))
    return ls

def getBam(wildcards):
    sample = config['samples'][wildcards.sample]
    return sample

rule all:
    input:
        bam2fastq_targets

rule bam2fastq:
    input:
        getBam
    output:
        fq1="data/{sample}/{sample}_1.fq.gz",
        fq2="data/{sample}/{sample}_2.fq.gz",
    threads: 4
    benchmark: "benchmarks/bam2fastq_{sample}.txt"
    shell:
        "samtools view -H {input} | grep \"^@RG\" > {wildcards.sample}.header && samtools collate -@ 32 -Ouf {input} | samtools fastq -@ 32 -1 {output.fq1} -2 {output.fq2} -t -s /dev/null -0 /dev/null -"
