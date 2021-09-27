configfile: "config.yaml"

import glob

def all_targets(wildcards):
    """Generates the targets for this module"""
    ls = []
    ls.append("rima_tx.benchmarks.txt")
    ls.append("rima_tx.src.txt")
    ls.append("rima_tx.config_meta.txt")
    ls.append("rima_tx.nohup.txt")
    return ls


rule target:
    input:
        all_targets

rule transfer_benchmarks:
    #input:
    #    "benchmarks/all_rima_targets.txt" #stub file b/c snkmk doesn't do dir
    params:
        transfer_path=config['transfer_path'],
    output:
        "rima_tx.benchmarks.txt"
    shell:
        """gsutil -m cp -r benchmarks {params.transfer_path} &&
        touch {output}"""

rule transfer_src:
    #input:
    #    "cidc_rima/rima.snakefile" #stub file b/c snkmk doesn't allow dirs
    params:
        transfer_path=config['transfer_path'],
    output:
        "rima_tx.src.txt"
    shell:
        """gsutil -m cp -r cidc_rima/ {params.transfer_path} &&
        touch {output}"""

rule transfer_config_meta:
    input:
        conf="config.yaml",
        meta="metasheet.csv",
    params:
        transfer_path=config['transfer_path']
    output:
        "rima_tx.config_meta.txt"
    shell:
        #NOTE: the *.yaml covers the config.yaml and the rima_auto config.yaml
        """gsutil -m cp -r *.yaml {params.transfer_path} &&
        gsutil -m cp -r {input.meta} {params.transfer_path} &&
        touch {output}"""

rule transfer_nohups:
    input:
        "nohup.out"
    params:
        transfer_path=config['transfer_path'],
        files=lambda wildcards: glob.glob('nohup*.out*')
    output:
        "rima_tx.nohup.txt"
    run:
        for f in params.files:
            shell("gsutil -m cp -r {f} {params.transfer_path}")
        shell("touch {output}")