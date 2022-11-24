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

# Compute t-SNE probability score matrix. #
# Args:
# X: A numeric data matrix.
# perplexity: Desired perplexity score for all variables. #
# Returns:
# A matrix of probability densities.
sam_tsne_p <- function(X, perplexity=15)
    {

    Kdist <- kNN(X, k=2*perplexity, approx=1)
    Kdist_idx <- Kdist$id
    Kdist_D <- Kdist$dist
    P <- matrix(0, nrow(X), nrow(X)) 
    D <- matrix(0, nrow(X), nrow(X)) 
    svals <- rep(1, nrow(X))
    #svals = as.array(Kdist_D[,perplexity])
    for (i in seq_along(svals)) {
        idx = Kdist_idx[i,]
        srange <- c(0, 100)
        #Find P_j|i and adapt sigma
        for(j in seq_len(50)) {
            Pji <- exp(-Kdist_D[i,] / (2 * svals[i]))  
            Pji <- Pji / sum(Pji) #normalize P_j|i
            H <- -1 * Pji %*% log(Pji, 2)
            if (H < log(perplexity, 2)){ #adapting sigma
                srange[1] <- svals[i] + 0.01
                svals[i] <- (svals[i] + srange[2]) / 2
                }
            else {
                srange[2] <- svals[i] + 0.01
                svals[i] <- (svals[i] + srange[1]) / 2
                } 
            }
        P[i, idx] <- Pji #saving the P_j|i values
        }
    #returning (P_j|i + P_i|j)/2n
    return(0.5 * (P + t(P)) / sum(P)) 

    }


# Compute t-SNE embeddings. #
# Args:
# X: A numeric data matrix.
# perplexity: Desired perplexity score for all variables.
# k: Dimensionality of the output.
# iter: Number of iterations to perform.
# rho: A positive numeric learning rate. #
# Returns:
# An nrow(X) by k matrix of t-SNE embeddings.

sam_tsne <- function(X, 
                      init=FALSE, 
                      perplexity=30, 
                      epochs = 50,
                      save_changes = FALSE,
                      momentum=list(init=.5, final=.9, iter=200L),
                      early_ex=list(factor=12, iter=200L),
                      eps_stop=1E-5,
                      k=2L, iter=1000L, rho=100) {
    
    #momentum variables
    mom_init = momentum$init
    mom_final = momentum$final
    mom_iter = momentum$iter
    mom_select <- function(i){ return(ifelse(i<mom_iter, mom_init, mom_final)) }
    #early exaggeration variables
    ee_factor <- early_ex$factor
    ee_iter <- early_ex$iter
    ee_select <- function(i){ return(ifelse(i<ee_iter, ee_factor, 1)) }
   
    
    #possibility of initialization of projection
    if(!is.matrix(init)) Y<- matrix(rnorm(nrow(X) * k), ncol = k) else Y<-as.matrix(init)
    
    # momentum list of Ys
    Y_old <- list()
    Y_old[[1]] <- Y
    Y_old[[2]] <- Y
    
    # saved outputs
    Y_save = list()
    Y_save[[1]] <- Y
    
    # KL values saving
    KL <- rep(0, iter)
    
    P <- sam_tsne_p(X, perplexity)     #high_dimensional affinities
    del <- matrix(0, nrow(Y), ncol(Y))
    for (inum in seq_len(iter)) {
    
        num <- 1 / ( 1 + as.matrix(dist(Y))^2 )   #low_dimensional affinities
        diag(num) <- 0
    
        Q <- num / sum(num)
        stiffnesses <- 4 * (ee_select(inum)*P - Q) * num 
    
        #cost function
        for (i in seq_len(nrow(X)))
            del[i, ] <- stiffnesses[i, ] %*% t(Y[i, ] - t(Y))
        
        #save KL value and add smallest machine epsilon to avoid failing of log function
        KL[inum] <- sum( P * log( (P+.Machine$double.eps)/(Q+.Machine$double.eps) ) )
    
        Y_old[[ inum%%2+1 ]] <- Y    
    
        #gradient descent
        Y <- Y - rho/ee_select(inum) * del - mom_select(inum)*(Y_old[[2]] - Y_old[[1]])
        
        #centering to 0
        Y <- t(t(Y) - apply(Y, 2, mean)) 
    
        if(save_changes)
            Y_save[[inum+1]] <- Y
    
        if( inum%%epochs==0 & inum>20 ){
            if( abs(KL[inum] - KL[inum-1]) < abs(KL[inum]*eps_stop) ){
                print(cat("Early stop at iteration ",inum,"\n",sep=""))
                if(save_changes) return(list(Y=Y,Y_save=Y_save)) else return(Y) 
            }
        }
    }
if(save_changes) return(list(Y=Y,Y_save=Y_save)) else return(Y) 
}