# fit a simple linear regression Y ~ X

method_lm <- function(
        dta,
        formula
) {
    
    fit <- lm(formula, data = dta)
    
    beta_hat <- coef(fit)
    beta_se <- sqrt(diag(vcov(fit)))
    conf_int <- confint(fit)
    
    return(list(beta_hat = beta_hat,
                beta_se = beta_se,
                conf_int = conf_int))
}
