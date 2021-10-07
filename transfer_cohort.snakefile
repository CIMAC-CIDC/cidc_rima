configfile: "config.yaml"

def all_targets(wildcards):
    """Generates the targets for this module"""
    ls = []
    for sample in config["samples"]:
      ls.append("cohort/%s/rima_tx.msi.txt" % sample)
      ls.append("cohort/%s/rima_tx.trust4.txt" % sample)
      ls.append("cohort/%s/rima_tx.microbiome.txt" % sample)
      ls.append("cohort/%s/rima_tx.fusion.txt" % sample)
      ls.append("cohort/%s/rima_tx.neoantigen.txt" % sample)
      ls.append("cohort/%s/rima_tx.star.txt" % sample)
      ls.append("cohort/%s/rima_tx.tin.txt" % sample)
      ls.append("cohort/%s/rima_tx.read.txt" % sample)
      ls.append("cohort/%s/rima_tx.salmon.txt" % sample)
      #ls.append("cohort/%s/rima_tx.genebody.txt" % sample)
    return ls


rule target:
    input:
      all_targets


rule transfer_msi_benchmarks:
    #input:
      #"benchmarks/all_rima_targets.txt" #stub file b/c snkmk doesn't do dir
    params:
      transfer_path=config['transfer_cohort_path'],
      msi_path = "analysis/msisensor/single/{sample}/",
    output:
      "cohort/{sample}/rima_tx.msi.txt"
    shell:
      """scp -i /home/aashna/.ssh/google_compute_engine  -r  {params.msi_path} {params.transfer_path}:/mnt/ssd/rima/rima/analysis/msisensor/ &&
          touch {output}"""


rule transfer_trust_benchmarks:
    #input:
      #"benchmarks/all_rima_targets.txt" #stub file b/c snkmk doesn't do dir
    params:
      transfer_path=config['transfer_cohort_path'],
      trust4_path = "analysis/trust4/{sample}",
    output:
      "cohort/{sample}/rima_tx.trust4.txt"
    shell:
      """gcloud  compute  scp  --tunnel-through-iap  --zone us-east1-b  --recurse  {params.trust4_path} {params.transfer_path}:/mnt/ssd/rima/rima/analysis/trust4/ &&
          touch {output}"""


rule transfer_microbiome_benchmarks:
    input:
      "analysis/microbiome/{sample}/{sample}_addSample_report.txt"
    params:
      transfer_path = config['transfer_cohort_path'],
      #microbiome_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/microbiome/%s/%s_addSample_report.txt" % (wildcards.sample, wildcards.sample),
      microbiome_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/microbiome/%s/" % (wildcards.sample),
      #new_instance_dir ="/mnt/ssd/rima/rima/analysis/microbiome/{sample}/"
    output:
      "cohort/{sample}/rima_tx.microbiome.txt"
    shell:
      """ssh -i /home/aashna/.ssh/google_compute_engine  {params.transfer_path} "mkdir -p {params.microbiome_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input} {params.transfer_path}:{params.microbiome_path} &&
         touch {output}"""


rule transfer_fusion_benchmarks:
    input:
      "analysis/fusion/{sample}/{sample}.fusion_predictions.abridged_addSample.tsv"
    params:
      transfer_path = config['transfer_cohort_path'],
      fusion_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/fusion/%s/" % (wildcards.sample),
    output:
      "cohort/{sample}/rima_tx.fusion.txt"
    shell:
      """ssh -i /home/aashna/.ssh/google_compute_engine {params.transfer_path} "mkdir -p {params.fusion_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input} {params.transfer_path}:{params.fusion_path} &&
         touch {output}"""

rule transfer_neontigen_benchmarks:
    input:
      "analysis/neoantigen/merge/{sample}.genotype.json"
    params:
      transfer_path = config['transfer_cohort_path'],
      neoantigen_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/neoantigen/%s/" % (wildcards.sample),
    output:
      "cohort/{sample}/rima_tx.neoantigen.txt"
    shell:
      """ssh -i /home/aashna/.ssh/google_compute_engine {params.transfer_path} "mkdir -p {params.neoantigen_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input} {params.transfer_path}:{params.neoantigen_path} &&
         touch {output}"""

rule transfer_star_benchmarks:
    input:
      "analysis/star/{sample}/{sample}.Log.final.out"
    params:
      transfer_path = config['transfer_cohort_path'],
      star_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/star/%s/" % (wildcards.sample),
    output:
      "cohort/{sample}/rima_tx.star.txt"
    shell:
      """ssh -i /home/aashna/.ssh/google_compute_engine {params.transfer_path} "mkdir -p {params.star_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input}  {params.transfer_path}:{params.star_path} &&
         touch {output}"""


rule transfer_tin_benchmarks:
    input:
      "analysis/rseqc/tin_score/{sample}/{sample}.summary.txt"
    params:
      transfer_path = config['transfer_cohort_path'],
      tin_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/rseqc/tin_score/%s/" % (wildcards.sample),
    output:
      "cohort/{sample}/rima_tx.tin.txt"
    shell:
      """ssh -i /home/aashna/.ssh/google_compute_engine  {params.transfer_path} "mkdir -p {params.tin_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input} {params.transfer_path}:{params.tin_path} &&
         touch {output}"""


rule transfer_read_distrib_benchmarks:
    input:
      "analysis/rseqc/read_distrib/{sample}/{sample}.txt"
    params:
      transfer_path = config['transfer_cohort_path'],
      read_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/rseqc/read_distrib/%s/" % (wildcards.sample),
    output:
      "cohort/{sample}/rima_tx.read.txt"
    shell:
      """ssh -i /home/aashna/.ssh/google_compute_engine  {params.transfer_path} "mkdir -p {params.read_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input} {params.transfer_path}:{params.read_path} &&
         touch {output}"""


rule transfer_gene_body_benchmarks:
    input:
      "analysis/rseqc/gene_body_cvg/{sample}/{sample}.geneBodyCoverage.r"
    params:
      transfer_path = config['transfer_cohort_path'],
      gb_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/rseqc/gene_body_cvg/%s/" % (wildcards.sample),
    output:
      "cohort/{sample}/rima_tx.genebody.txt"
    shell:
      """ssh  -i /home/aashna/.ssh/google_compute_engine {params.transfer_path} "mkdir -p {params.gb_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input} {params.transfer_path}:{params.gb_path} &&
         touch {output}"""


rule transfer_salmon_benchmarks:
    input:
      "analysis/salmon/{sample}/{sample}.quant.sf"
    params:
      transfer_path = config['transfer_cohort_path'],
      salmon_path = lambda wildcards: "/mnt/ssd/rima/rima/analysis/salmon/%s/" % (wildcards.sample),
    output:
      "cohort/{sample}/rima_tx.salmon.txt"
    shell:
      """ssh -i /home/aashna/.ssh/google_compute_engine {params.transfer_path} "mkdir -p {params.salmon_path}" &&"""
      """scp  -i /home/aashna/.ssh/google_compute_engine  -r  {input} {params.transfer_path}:{params.salmon_path} &&
         touch {output}"""