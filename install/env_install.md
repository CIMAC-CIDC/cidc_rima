# RIMA installation guide
 The RIMA pipeline piles together many different software tools and packages, each of which has its own set of dependancies. 
 In fact, some of these dependancies are incompatible with each other, and in these cases, we have to create separate environments for conflicting tools.
 This guide aims to help the user create a working series of environments to run the entire RIMA pipeline.

### Cloning RIMA repository and basic setup
  All of the code and scripts required to run RIMA are in the cidc_rima   repository. Our first step is to clone the repo so that we have access to it on our local system. (We like to clone our repositories in the /mnt/ssd/rima directory). 
  To clone the repo, we can use the following command. If it works, you will see a new directory called cidc_wes.

   1.    >  git clone git@bitbucket.org:plumbers/cidc_rima.git

---

### Creating RIMA environment



### Installing conda environments for different tools
  Within the cidc_rima repository, there are several yaml files that can be used to create the conda environments that the RIMA pipeline needs to run. We can start off the process by navigating to the cidc_rima/env_yml_files directory and creating the RIMA environment using the following commands. 

2.  > cd cidc_rima/env_yml_files

The command above puts us in the cidc_rima/env_yml_files folder where the yml files are located

3. >  conda env export | grep -v "^prefix: " > "environment_name"

The above command creates and updates the enviroment that you mention in the `"environment_name"`

              
 
    For exmaple the environments that need to be generated are in rima.snakefile in rule:
        `def addCondaPaths_Config(config)` 
    and where it says: 
    `_config['rnaseq_root'] = "%s/envs/rnaseq_new" % conda_root_`
    then it means we can create s `rnaseq_new` environment using the following:
     `conda env export | grep -v "^prefix: " > "rnaseq_new"`
 
 
As you can see in rima.snakefile, there are around six enviroments `rnaseq_new:prada_env`. Type each environment name in third command and see the iles generated in the env_yaml_files/ folder

---

## RIMA environment:
    
    For reference:
    Conda info --envs (command will help you look at environments you created or activated). In our case you should see the following and '*' indicates that the cuurent environment is activated
    # conda environments:
    #
    rnaseq_new        *  /home/aashna/miniconda3/envs/rnaseq_new
    stat_perl_r          /home/aashna/miniconda3/envs/stat_perl_r
    vep_env              /home/aashna/miniconda3/envs/vep_env
    centrifuge_env       /home/aashna/miniconda3/envs/centrifuge_env
    gatk4_env            /home/aashna/miniconda3/envs/gatk4_env
    prada_env            /home/aashna/miniconda3/envs/prada_env

---

## Download set up pre-built references
 A pre-prepared RIMA reference folder can be downloaded using the code below.

 If you want to prepare a customized reference, you can follow this [tutorial](https://liulab-dfci.github.io/RIMA/customize-your-own-reference.html) to build your own reference.

 The following link contains the hg38 reference downloaded from [Genomic Data Commons](https://gdc.cancer.gov/about-data/gdc-data-processing/gdc-reference-files) using version 22 index and annotation files.

download wherever rima folder and rima.snakefile are
 > wget http://cistrome.org/~lyang/ref.tar.gz  

unzip the reference  
 > tar -zxvf ref.tar.gz

remove the reference zip file to save some space (optional)
 > rm ref.tar.gz 

_Cross check in the ref.yaml file to see if the location of the files given matches what is in ref.yaml script, if not make changes to it_


---
## Running the pipeline


Check the pipeline with a dry run to ensure correct script and data usage.

>snakemake -s RIMA.snakefile -np 


**Submit the job**  

Alignment and some of the other modules of RIMA will take several hours to run. It is recommended that you run RIMA in the background using a command such as nohup as below.

>nohup time snakemake -p -s RIMA.snakefile -j 4 > RIMA.out &

_Note: Argument -j sets the cores for parallel runs (e.g. ‘-j 4’ can run 4 jobs in parallel at the same time.). Argument -p prints the command in each rule. Note: Here, output log records the run information. A user may run one module at a time to obtain a record of each module’s output log._

---
## Versions

    Python = 3.7.6
    R version =3.2.2


 
