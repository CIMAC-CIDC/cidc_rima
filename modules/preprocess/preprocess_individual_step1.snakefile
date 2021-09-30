_preprocess_threads = 64

import pandas as pd
metadata = pd.read_csv(config["metasheet"], index_col=0, sep=',')

gz_command = "--readFilesCommand zcat" if config["samples"][metadata.index[0]][0][-3:] == '.gz' else ""

def align_targets(wildcards):
    ls = []
    for sample in config["samples"]:
        ls.append("analysis/star/%s/%s.unsorted.bam" % (sample,sample))
        ls.append("analysis/star/%s/%s.sorted.bam" % (sample, sample))
        ls.append("analysis/star/%s/%s.transcriptome.bam" % (sample, sample))
        ls.append("analysis/star/%s/%s.Chimeric.out.junction" % (sample, sample))
        ls.append("analysis/star/%s/%s.Log.final.out" % (sample, sample))
        ls.append("analysis/star/%s/%s.counts.tab" % (sample, sample))
        ls.append("analysis/star/%s/%s.sorted.bam.stat.txt" % (sample, sample))
        #ls.append("analysis/star/%s/%s.sorted.bam.bai" % (sample, sample))
    return ls


def align_getFastq(wildcards):
    ls = config["samples"][wildcards.sample]
    return ls

def align_getBam(wildcards):
    bam = config["samples"][wildcards.sample][0] #returns only the first elm
    return bam

rule align_all:
    input:
       align_targets
    benchmark: "benchmarks/align/align_all.txt"


def aggregate_align_input(wildcards):
    # handle .bam files separately from .fastq files
    #check only the first file
    sample_first_file = config["samples"][wildcards.sample][0]
    if sample_first_file.endswith(".bam"):
        return ["analysis/star/{sample}/{sample}.sorted.fromBam.bam",
                "analysis/star/{sample}/{sample}.sorted.fromBam.bam.bai",
		"analysis/star/{sample}/{sample}.transcriptome.fromBam.bam",
		"analysis/star/{sample}/{sample}.Chimeric.out.fromBam.junction",
		"analysis/star/{sample}/{sample}.counts.fromBam.tab",
		"analysis/star/{sample}/{sample}.Log.final.fromBam.out",
		"analysis/star/{sample}/{sample}.unsorted.fromBam.bam"]
    else:
        return ["analysis/align/{sample}/{sample}.sorted.fromFastq.bam",
                "analysis/align/{sample}/{sample}.sorted.fromFastq.bam.bai",
                "analysis/star/{sample}/{sample}.transcriptome.fromFastq.bam",
                "analysis/star/{sample}/{sample}.Chimeric.out.fromFastq.junction",
                "analysis/star/{sample}/{sample}.counts.fromFastq.tab",
                "analysis/star/{sample}/{sample}.Log.final.fromFastq.out",
		"analysis/star/{sample}/{sample}.unsorted.fromFastq.bam"]


rule aggregate_input:
    input:
      aggregate_align_input
    params:
      bam = lambda wildcards,input: input[0],
      bai = lambda wildcards,input: input[1],
      transcriptome = lambda wildcards,input: input[2],
      chimeric = lambda wildcards,input: input[3],
      counts = lambda wildcards,input: input[4],
      logf = lambda wildcards,input: input[5],
      unsorted = lambda wildcards,input: input[6]
    output:
      bam="analysis/star/{sample}/{sample}.sorted.bam",
      bai="analysis/star/{sample}/{sample}.sorted.bam.bai",
      transcriptome="analysis/star/{sample}/{sample}.transcriptome.bam",
      chimeric="analysis/star/{sample}/{sample}.Chimeric.out.junction",
      counts= "analysis/star/{sample}/{sample}.counts.tab",
      logf="analysis/star/{sample}/{sample}.Log.final.out",
      unsorted="analysis/star/{sample}/{sample}.unsorted.bam"
    shell:
      "mv {params.bam} {output.bam} && mv {params.bai} {output.bai} && mv {params.transcriptome} {output.transcriptome}"
      "&& mv {params.chimeric} {output.chimeric} && mv {params.counts} {output.counts} && mv {params.logf} {output.logf} && mv {params.unsorted} {output.unsorted}"

rule align_from_bam:
    input:
      align_getBam
    output:
      fq1 = "analysis/star/{sample}/{sample}_R1.fq",
      fq2 = "analysis/star/{sample}/{sample}_R2.fq",
      unsortedBAM = "analysis/star/{sample}/{sample}.unsorted.fromBam.bam",
      sortedBAM = "analysis/star/{sample}/{sample}.sorted.fromBam.bam",
      sortedbai="analysis/star/{sample}/{sample}.sorted.fromBam.bam.bai",
      transcriptomeBAM = "analysis/star/{sample}/{sample}.transcriptome.fromBam.bam",
      junction_file = "analysis/star/{sample}/{sample}.Chimeric.out.fromBam.junction",
      counts = "analysis/star/{sample}/{sample}.counts.fromBam.tab",
      log_file = "analysis/star/{sample}/{sample}.Log.final.fromBam.out"
    threads: 64 #_bwa_threads
    priority: 100
    params:
      gz_support = gz_command,
      prefix = lambda wildcards: "analysis/star/{sample}/{sample}".format(sample=wildcards.sample),
      awk_cmd=lambda wildcards: "awk -v OFS=\'\\t\' \'{ split($2,a,\":\"); read_id=a[2]; $2=\"ID:%s.\" read_id; gsub(/SM:.+\\t/,\"SM:%s\\t\"); print $0}\'" % (wildcards.sample, wildcards.sample),
      gawk_cmd=lambda wildcards: "gawk -v OFS=\'\\t\' \'{rg=match($0,/RG:Z:(\S+)/,a); read_id=a[1]; if (rg) {sub(/RG:Z:\S+/, \"RG:Z:%s.\" read_id, $0); print $0} else { print $0 }}\'" % wildcards.sample,
    benchmark: "benchmarks/align/{sample}/{sample}.align_from_bam.txt"
    shell:
      """samtools view -H {input} | grep \"^@RG\" > {wildcards.sample}.header"""
      """&& samtools collate -@ 32 -Ouf {input} | samtools fastq -@ 32 -1 {output.fq1} -2 {output.fq2} -t -s /dev/null -0 /dev/null -|STAR --runThreadN {threads} --genomeDir {config[star_index]} --outReadsUnmapped None --chimSegmentMin 12 --chimJunctionOverhangMin 12 --chimOutJunctionFormat 1 --alignSJDBoverhangMin 10 --alignMatesGapMax 1000000  --alignIntronMax 1000000 --alignSJstitchMismatchNmax 5 -1 5 5 --outSAMstrandField intronMotif --outSAMunmapped Within --outSAMtype BAM Unsorted --readFilesIn {output.fq1} {output.fq2} --chimMultimapScoreRange 10  --chimMultimapNmax 10  --chimNonchimScoreDropMin 10  --peOverlapNbasesMin 12 --peOverlapMMp 0.1 --genomeLoad NoSharedMemory --outSAMheaderHD @HD VN:1.4 --twopassMode Basic {params.gz_support} --outFileNamePrefix {params.prefix} --quantMode TranscriptomeSAM GeneCounts"""
      """ && mv {params.prefix}Aligned.out.bam {output.unsortedBAM}"""
      """ && samtools sort -T {params.prefix}TMP -o {output.sortedBAM} -@ 32  {output.unsortedBAM} """
      """ && mv {params.prefix}Aligned.toTranscriptome.out.bam {output.transcriptomeBAM}"""
      """ && mv {params.prefix}ReadsPerGene.out.tab {output.counts}"""
      """ && mv {params.prefix}Chimeric.out.junction {output.junction_file}"""
      """ && mv {params.prefix}Log.final.out {output.log_file}"""
      """ && samtools index {output.sortedBAM} {output.sortedbai}"""

rule align_from_fastq:
    input:
      align_getFastq
    output:
      unsortedBAM = "analysis/star/{sample}/{sample}.unsorted.fromFastq.bam",
      sortedBAM = "analysis/star/{sample}/{sample}.sorted.fromFastq.bam",
      sortedbai = "analysis/star/{sample}/{sample}.sorted.fromFastq.bam.bai",
      transcriptomeBAM = "analysis/star/{sample}/{sample}.transcriptome.fromFastq.bam",
      junction_file = "analysis/star/{sample}/{sample}.Chimeric.out.fromFastq.junction",
      counts = "analysis/star/{sample}/{sample}.counts.fromFastq.tab",
      log_file = "analysis/star/{sample}/{sample}.Log.final.fromFastq.out"
    params:
      gz_support = gz_command,
      prefix = lambda wildcards: "analysis/star/{sample}/{sample}".format(sample=wildcards.sample)
    threads: _preprocess_threads
    message:
      "Running STAR Alignment on {wildcards.sample}"
    log:
      "logs/star/{sample}.star_align.log"
    benchmark:
      "benchmarks/star/{sample}.star_align.benchmark"
    conda:
      "../envs/star_env.yml"
    shell:
      "STAR --runThreadN {threads} --genomeDir {config[star_index]} --outReadsUnmapped None --chimSegmentMin 12 --chimJunctionOverhangMin 12 --chimOutJunctionFormat 1 --alignSJDBoverhangMin 10 --alignMatesGapMax 1000000  --alignIntronMax 1000000 --alignSJstitchMismatchNmax 5 -1 5 5 --outSAMstrandField intronMotif --outSAMunmapped Within --outSAMtype BAM Unsorted --readFilesIn {input} --chimMultimapScoreRange 10  --chimMultimapNmax 10  --chimNonchimScoreDropMin 10  --peOverlapNbasesMin 12 --peOverlapMMp 0.1 --genomeLoad NoSharedMemory --outSAMheaderHD @HD VN:1.4 --twopassMode Basic {params.gz_support} --outFileNamePrefix {params.prefix} --quantMode TranscriptomeSAM GeneCounts"
      " && mv {params.prefix}Aligned.out.bam {output.unsortedBAM}"
      " && samtools sort -T {params.prefix}TMP -o {output.sortedBAM} -@ 8  {output.unsortedBAM} "
      " && mv {params.prefix}Aligned.toTranscriptome.out.bam {output.transcriptomeBAM}"
      " && mv {params.prefix}ReadsPerGene.out.tab {output.counts}"
      " && mv {params.prefix}Chimeric.out.junction {output.junction_file}"
      " && mv {params.prefix}Log.final.out {output.log_file}"
      " && samtools index {output.sortedBAM} {output.sortedbai}"