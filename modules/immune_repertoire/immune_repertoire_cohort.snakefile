#!/usr/bin/env python

#-------------------------------Immune Repertoire Cohort -----------------------------#
###############-------------Module to draw cohort plot--------------------##############

def immune_repertoire_cohort_targets(wildcards):
    ls = []
    ls.append("files/multiqc/immunerepertoire/TRUST4-BCR_mqc.png")
    ls.append("files/multiqc/immunerepertoire/TRUST4-TCR_mqc.png")
    ls.append("files/multiqc/immunerepertoire/TRUST_Ig.txt")
    return ls

rule immune_repertoire_cohort_all:
    input:
      immune_repertoire_cohort_targets

rule trust4_cohort_plot:
   input:
      "files/immune_repertoire/TRUST4_BCR_light.Rdata",
      "files/immune_repertoire/TRUST4_BCR_heavy.Rdata",
      "files/immune_repertoire/TRUST4_TCR.Rdata",
      "files/immune_repertoire/TRUST4_BCR_heavy_cluster.Rdata",
      "files/immune_repertoire/TRUST4_BCR_heavy_clonality.Rdata",
      "files/immune_repertoire/TRUST4_BCR_heavy_SHMRatio.Rdata",
      "files/immune_repertoire/TRUST4_BCR_heavy_lib_reads_Infil.Rdata",
      "files/immune_repertoire/TRUST4_BCR_Ig_CS.Rdata",
      "files/immune_repertoire/TRUST4_TCR_clonality.Rdata",
      "files/immune_repertoire/TRUST4_TCR_lib_reads_Infil.Rdata"
   output:
      "files/multiqc/immunerepertoire/TRUST4-BCR_mqc.png",
      "files/multiqc/immunerepertoire/TRUST4-TCR_mqc.png",
      "files/multiqc/immunerepertoire/TRUST_Ig.txt"
   log:
      "logs/trust4/trust4_plot.log"
   benchmark:
      "benchmarks/trust4/trust4_plot.benchmark"
   conda: "../envs/stat_perl_r.yml"
   params:
      inputdir = "files/immune_repertoire/",
      phenotype_col=config["immunerepertoire_clinical_phenotype"],
      meta=config['metasheet'],
      plot_dir="files/multiqc/immunerepertoire/",
      path="set +eu;source activate %s" % config['stat_root'],
   shell:
      "{params.path}; Rscript src/immune_repertoire/trust4_plot.R --input_path {params.inputdir} --outdir {params.plot_dir} --meta {params.meta} --clinic_col {params.phenotype_col}"
