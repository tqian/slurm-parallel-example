# a simple generative model based on linear regression
dgm_lm <- function(
        sample_size,
        error_distribution
) {
    
    beta_true <- c(1, 2)
    beta0 <- beta_true[1]
    beta1 <- beta_true[2]
    
    df_names <- c("id", "X", "Y")
    dta <- data.frame(matrix(NA, nrow = sample_size, ncol = length(df_names)))
    names(dta) <- df_names
    
    dta$id <- 1:sample_size
    dta$X <- rnorm(nrow(dta))
    
    if (error_distribution == "normal") {
        epsilon <- rnorm(nrow(dta))
    } else if (error_distribution == "uniform") {
        epsilon <- runif(nrow(dta), min = -1, max = 1)
    } else {
        stop("Unsupported error_distribution type.")
    }
    
    dta$Y <- beta0 + beta1 * dta$X + epsilon
    
    return(dta)
}