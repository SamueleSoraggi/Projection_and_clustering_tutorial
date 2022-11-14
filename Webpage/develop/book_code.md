# Book function for probabilities

```
# Compute t-SNE probability score matrix. #
# Args:
# X: A numeric data matrix.
# perplexity: Desired perplexity score for all variables. #
# Returns:
# A matrix of probability densities.
casl_tsne_p <- function(X, perplexity=15)
    {
    
    D <- as.matrix(dist(X))^2
    P <- matrix(0, nrow(X), nrow(X)) 
    
    svals <- rep(1, nrow(X))
    for (i in seq_along(svals)) {
        srange <- c(0, 100)
        for(j in seq_len(50)) {
            Pji <- exp(-D[i, -i] / (2 * svals[i]))  
            Pji <- Pji / sum(Pji)
            H <- -1 * Pji %*% log(Pji, 2)
            if (H < log(perplexity, 2)){
                srange[1] <- svals[i]
                svals[i] <- (svals[i] + srange[2]) / 2
                }
            else {
                srange[2] <- svals[i]
                svals[i] <- (svals[i] + srange[1]) / 2
                } 
            }
        P[i, -i] <- Pji
        }
    return(0.5 * (P + t(P)) / sum(P)) 
    }
```

# Book function for running tSNE

```
# Compute t-SNE embeddings. #
# Args:
# X: A numeric data matrix.
# perplexity: Desired perplexity score for all variables.
# k: Dimensionality of the output.
# iter: Number of iterations to perform.
# rho: A positive numeric learning rate. #
# Returns:
# An nrow(X) by k matrix of t-SNE embeddings.

casl_tsne <- function(X, init=FALSE, perplexity=30, k=2L, iter=1000L, rho=100) {
    
    #possibility of initialization of projection
    if(!is.matrix(init)) Y <- matrix(rnorm(nrow(X) * k), ncol = k) else Y <- init
    
    P <- casl_tsne_p(X, perplexity) 
    del <- matrix(0, nrow(Y), ncol(Y))
    for (inum in seq_len(iter)) {
        num <- matrix(0, nrow(X), nrow(X))
        for (j in seq_len(nrow(X))) { 
            for (k in seq_len(nrow(X))) {
                num[j, k] = 1 / (1 + sum((Y[j,] - Y[k, ])^2)) 
            }
        }
    diag(num) <- 0
    Q <- num / sum(num)
    stiffnesses <- 4 * (P - Q) * num 
    for (i in seq_len(nrow(X))){
        del[i, ] <- stiffnesses[i, ] %*% t(Y[i, ] - t(Y))
    }
    Y <- Y - rho * del
    Y <- t(t(Y) - apply(Y, 2, mean)) 
    }
return(Y)  
}
```