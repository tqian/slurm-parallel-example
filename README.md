# Embarrassingly Parallel Simulation on UCI HPC3

This repository demonstrates how to run an embarrassingly parallel simulation using R on a Slurm-based high-performance computing (HPC) cluster-specifically, the UCI HPC3 system. The simulation splits the overall workload into multiple array jobs that run in parallel and then aggregates temporary results. A separate slurm job can be run to compute the “true” parameter value from a very large data set.

## Prerequisites

- **HPC Environment:**  
    Access to a Slurm-based HPC cluster (e.g., UCI HPC3) is required.

## Quick Start

```bash
# Upload the entire directory to HPC
# (Make sure out_and_err_files/ subdirectory exists)

# Submit parallel simulation job
sbatch batch_simulation.sh

# Look at the result files, and possibly temporary files, to see if code ran correctly.

# Clean up temporary files
sbatch clean_folders.sh

# Submit job to compute true values
sbatch compute_truth.slurm

# Additional R code to analyze the simulation result, make plots, etc. (not included here)
```

## How It Works

### 1. Simulation Execution
- **Array Job Submission:** 
    Run:
    ```bash
    sbatch batch_simulation.sh
    ```
    This submits an array job with **60 tasks**.    
    **Array Size Calculation:** 
    The array size (60) is the number of rows in the factorial simulation design data frame. In the `simulation_R_code.R` file, the matrix is constructed as follows:
    - A vector of seeds is defined with length `nsim / nsim_per_task` (e.g., 1000/100 = 10 seeds),
    - There are 2 error distribution options ("normal" and "uniform"),
    - There are 3 sample sizes (30, 50, 100).   
    Thus, the total number of rows is:  
    `10 (seeds) * 2 (error distributions) * 3 (sample sizes) = 60`.

- **Task-Specific Simulation:** 
    The `simulation_R_code.R` script:
    - Reads its task ID to extract simulation parameters,
    - Runs `nsim_per_task` replications, generating data, fitting a linear model, and saving each replication’s result,
    - Saves results to `result_tmp/` and, for each configuration (ignoring seed), one task aggregates all results into `result_collected/`.

### 2. Truth Computation
- **Computing True Parameter Values:**  
    Run:
    ```bash
    sbatch compute_truth.slurm
    ```
    The `compute_truth.R` script:
    - Generates a very large dataset (sample size = 1,000,000) for both "normal" and "uniform" error distributions,
    - Fits a linear model for each,
    - Extracts the estimated coefficients, and
    - Writes the benchmark results to `beta_true.csv`.

### 3. Cleanup
- **Removing Temporary Files:** 
    After simulations are complete and results are aggregated, and you have verified the results are OK, you can clean up by running:
    ```bash
    sbatch clean_folders.sh
    ```
    Note that this deletes everything in `result_tmp/` and `out_and_err_files/`. These files can be useful for diagnosing problems so be mindful before deleting them.

## Repository Structure

- **batch_simulation.sh**	
	Submits a Slurm array job that runs the simulation multiple times concurrently. This script calls the `simulation.slurm` file for each array job.

- **simulation.slurm**	
	A Slurm batch script for each array task. It sets up the environment, loads the necessary modules, and calls the main R simulation script (`simulation_R_code.R`), passing the task ID as an argument.

- **simulation_R_code.R**	
	The main R script for running simulation replications:
	- **Reads simulation parameters:** Uses the task ID to select a row from a factorial simulation design (varying seed, error distribution, and sample size).
	- **Performs replications:** Runs multiple simulation replications (using a data-generating model and linear regression fitting).
	- **Saves temporary results:** Each task writes results into `result_tmp/`.
	- **Aggregates results:** For each simulation configuration (ignoring the seed), one designated task waits for all related tasks to complete, aggregates their output, and saves the combined results in `result_collected/`.

- **compute_truth.slurm**	
	A Slurm batch script to launch a single job that runs the truth computation.

- **compute_truth.R**	
	An R script that computes the “true” parameter values. It:
	- Generates a very large dataset using both normal and uniform error distributions.
	- Fits a linear model for each case.
	- Extracts the estimated coefficients.
	- Writes the combined results to a CSV file (`beta_true.csv`).

- **clean_folders.sh**	
	A shell script that cleans up intermediate files:
	- Removes all files in the `out_and_err_files/` folder.
	- Removes temporary result files from `result_tmp/`.

- **function/dgm_lm.R**	
	Contains the function `dgm_lm`, which implements a data generating mechanism (DGM) for a simple linear model. This script:
	- Simulates predictor data.
	- Generates the outcome variable according to a specified error distribution ("normal" or "uniform").
	- Returns a data frame suitable for model fitting.

- **function/method_lm.R**	
	Contains the function `method_lm`, which fits a simple linear regression model. It:
	- Fits a model using R's `lm()` function.
	- Extracts the model’s coefficient estimates, standard errors, and confidence intervals.
	- Returns these values as a list.

- **Other Directories:**
	- `out_and_err_files/`: Contains the Slurm output and error files to help diagnose issues.
	- `result_tmp/`: Stores the individual temporary result files from each simulation task.
	- `result_collected/`: Contains aggregated results for each simulation configuration.

## Future-Proofing and Technical Considerations

### Checking R Version on the Cluster

```bash
module avail R
```

You can update the `module load R/4.3.3` line in `simulation.slurm` and `compute_truth.slurm` accordingly.

### Package Management Through Interactive R Sessions

If you R code requires loading certain packages such as `tidyverse`, you can use the following steps to install the package before running the batch job. (The package installation only needs to be run once.)

1. Login to HPC:
	 ```bash
	 ssh your_netid@hpc3.rcic.uci.edu
	 ```

2. Start an interactive compute node session:
	 ```bash
	 salloc --time=01:00:00 --mem=2G --ntasks=1
	 ```

3. Load R module:
	 ```bash
	 module load R/4.3.3
	 ```

4. Start R:
	 ```bash
	 R
	 ```

5. Install packages in R (such as tidyverse):
	 ```r
	 install.packages("tidyverse")
	 ```

6. Quit R and end session:
	 ```r
	 quit()
	 ```

### Memory Requirements

Change `--mem-per-cpu=4G` to higher or lower in `simulation.slurm` and `compute_truth.slurm` depending on the memory need.

### Adjusting the Array Size

Update 60 in `seq 60` in the file `batch_simulation.sh` to other quantity based on the number of rows in your simulation design matrix.


## Contact

For any questions or feedback, please contact Tianchen Qian at t.qian@uci.edu.
