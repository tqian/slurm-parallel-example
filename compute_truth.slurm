#!/bin/bash

#SBATCH --job-name=truth            ## job name
#SBATCH -p standard                 ## HPC partition to use
#SBATCH -A tiancq1_lab              ## charge time to Tianchen's lab account
#SBATCH --nodes=1                   ## use 1 node, don't ask for multiple
#SBATCH --ntasks=1                  ## number of tasks to launch
#SBATCH --cpus-per-task=1           ## number of cores the job needs
#SBATCH --mem-per-cpu=4G            ## ask for 4Gb memory per CPU
#SBATCH --error=out_and_err_files/%x.%A.err    ## Slurm error  file, %x - job name, %A job id
#SBATCH --out=out_and_err_files/%x.%A.out      ## Slurm output file, %x - job name, %A job id

module load R/4.3.3 # load R
Rscript compute_truth.R
