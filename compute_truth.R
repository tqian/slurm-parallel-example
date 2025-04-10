library(tidyverse)

source("function/dgm_lm.R")
source("function/method_lm.R")

large_sample_size_number <- 1000000

set.seed(123)
dta_huge <- dgm_lm(sample_size = large_sample_size_number, error_distribution = "normal")
fit_normal <- method_lm(dta_huge, formula = Y~X)
beta_true_normal <- fit_normal$beta_hat

set.seed(123)
dta_huge <- dgm_lm(sample_size = large_sample_size_number, error_distribution = "uniform")
fit_uniform <- method_lm(dta_huge, formula = Y~X)
beta_true_uniform <- fit_uniform$beta_hat

# Write the data frame to a CSV file.
beta_true <- as.data.frame(rbind(beta_true_normal, beta_true_uniform))
beta_true$error_distribution <- c("normal", "uniform")
write_csv(beta_true, file = "beta_true.csv")
