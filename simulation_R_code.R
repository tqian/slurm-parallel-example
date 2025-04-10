library(tidyverse)

args <- commandArgs(trailingOnly = TRUE) # reads in the task id
itask <- as.integer(args[1])

nsim <- 1000
nsim_per_task <- 100
seed <- 1:(nsim / nsim_per_task)

print_every_n_sims <- 10

simulation_design <- expand.grid(
    seed = seed,
    error_distribution = c("normal", "uniform"),
    sample_size = c(30, 50, 100)
)

source("function/dgm_lm.R")
source("function/method_lm.R")


error_distribution <- simulation_design$error_distribution[itask]
sample_size <- simulation_design$sample_size[itask]
seed <- simulation_design$seed[itask]

print("Conducting simulation for...\n")

print(simulation_design[itask, ])

set.seed(seed)

result_collected <- c()

start_time <- Sys.time()
for (isim in 1:nsim_per_task) {
    
    # keep track of running time (useful for jobs that takes a long time to run)
    if (isim %% print_every_n_sims == 0) {
        current_time <- Sys.time()
        hours_diff <- round(difftime(current_time, start_time, units = "hours"), 2)
        cat(paste0("Starting isim: ", isim, "/", nsim_per_task, "; Hours lapsed: ", hours_diff, "\n"))
    }
    
    dta <- dgm_lm(sample_size = sample_size, error_distribution = error_distribution)
    
    # Fit model using tryCatch so that the simulation still runs even if certain
    # iterations result in error (e.g., singular matrix, etc.)
    # (This simple illustration won't result in any error. But for more complicated
    # dgm and more complicated methods, errors due to "unlucky dataset" are possible.)
    model_fit <- tryCatch({
        # Attempt to run the model fitting code
        fit <- method_lm(dta, formula = Y ~ X)
        fit
    }, error = function(e) {
        # In case of any error, return the error message
        list(error_message = conditionMessage(e))
    })
    result_collected <- c(result_collected, list(model_fit))
}

print("The model_fit object from the last iteration is:")
print(model_fit)

dir.create("result_tmp", showWarnings = FALSE)
saveRDS(result_collected, file = paste0("result_tmp/", itask, ".RDS"))


if (seed == (nsim / nsim_per_task)) {
    # The last parallel task for each row of simulation_design
    # will wait till all tasks for that row are finished and then collect results.
    
    simulation_design_to_collect <- 
        simulation_design[itask, names(simulation_design) != "seed"]
    
    print("Collecting result files for:")
    print(simulation_design_to_collect)
    
    # Assume simulation_design_to_collect is a single-row data frame
    match_row <- simulation_design_to_collect[1, ]
    
    # Find the row indices in simulation_design where the first two columns match
    itask_to_collect <- which(
            simulation_design$sample_size == match_row$sample_size &
            simulation_design$error_distribution == match_row$error_distribution
    )
    
    all_result_files <- paste0("result_tmp/", itask_to_collect, ".RDS")
    
    while (!all(file.exists(all_result_files))) {
        Sys.sleep(5)
    }
    
    result_collected <- list()
    for (ifile in all_result_files) {
        result_from_ifile <- readRDS(ifile)
        result_collected <- c(result_collected, result_from_ifile)
    }
    
    dir.create("result_collected", showWarnings = FALSE)
    saveRDS(result_collected, file = paste0("result_collected/", 
                                          "error_distribution=", match_row$error_distribution,
                                          ",sample_size=", match_row$sample_size,
                                          ".RDS"))
}
