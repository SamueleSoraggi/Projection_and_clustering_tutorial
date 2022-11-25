# Exercise

**Depending on your coding skills**, you can decide how much you want to do for the assignment. Also fiddling with a tutorial and trying out things can be ok :) To run one of the tutorials, you need to download the file `functions.R` in the folder `Code` of the repository ([click here](https://github.com/SamueleSoraggi/Projection_and_clustering_tutorial/blob/main/Code/functions.R)). Put the file inside the same folder where you are coding. This file contains also the solution to the exercise, so you can compare how you try to solve the assignment and how I did it (but don't cheat!).

1) Choose a dataset or work on one of the examples you can find in the menu under `Code`. Various datasets are present in the folder `Data` of this github repository ([link here](https://github.com/SamueleSoraggi/Projection_and_clustering_tutorial/tree/main/Data)), or you can type the function `data()` in R to open one of many datasets, such as `data(decathlon)`, `data(iris)` or `data(Cars93)`. I documented the data under the `Datasets` menu.

2) Feel free to Copy-paste the code for the exercise from the book, so that you define the functions for tSNE. You can copy the code also here from the section `Code-->Book code`. Alternatively, download and source the file [`functions.R`](https://github.com/SamueleSoraggi/Projection_and_clustering_tutorial/blob/main/Code/functions.R) into your code.

Then do what follows.

## Projection

- Try to run various projection methods as in the tutorials. You can reuse any of the tutorials to recycle some code. 

- Try some optional parameters in kernel PCA, tSNE and UMAP. See how the perplexity and learning rate `rho` of tSNE are influential in the result. Use the help to see the documentation of a function, for example `help(PCA)`. Try also all the UMAP parameters (`a`, `b`, `learning_rate`, `neighbors`)

- Does your data shows some patterns in your projections? Do you have any outliers? Are there some clear separations into categories?

- Try to implement one or more improvements, here listed in order of difficulty of implementation:
  - faster calculation of affinities `Pji` in low dimension, avoiding the nested for loops
  - early stop criteria on the KL divergence
  - early exaggeration 
  - momentum addition to gradient descent

- Every time you improve your function, compare new and old code with `microbenchmark` as in the example notebooks. To do this, copy the book functions and give them a new name. If you do that in the file `functions.R`, benchmark also against the `sam_tsne` function.

## Clustering

The decathlon example right now contains all code you need to apply clustering.
Choose your best projection between tSNE or UMAP. Then try to apply the following clustering methods to your data:

- **k-means**: try various amounts of centroids. Then try to choose them with the elbow method or with the help of hierarchical clustering. Do you get some meaningful clusters? Are there small clusters?

- **hierarchical**: try out various linkage methods and tree-cutting thresholds. Is there any result that seems really better than others when looking at the clustering plot?

- **density clustering**: try `dbscan` and see how changing the `eps` parameters can really change a lot the output. Try also to change from using the standard distance `dist` for the input, into using kernel distances (such as gaussian kernel or the t-distribution kernel used in tSNE) or other methods implemented in the function `dist`. This might make the clustering different. Try `hdbscan` and see the differences with previous clusterings.

- Choose one clustering and try to find out if any feature (or group of features) of your data popo to your eye being different across clusters.

### Bonus exercise

We try out implementing on our own the simplest spectral clustering algorithm. To do this we need to first build the adjacency matrix of the graph representing the data.

- We can build the adjacency matrix using the KNN function to calculate the nearest neighbors, and for each i-th point of the data, fill a matrix of zeros with a transformation of the distances to the nearest neighbors. This is a simple code that does that by transforming distances with a negative exponential kernel. You can use others, such as the gaussian kernel.
```
spectr_k <- 5
Kdist <- kNN(proj, k=spectr_k)
Kdist_idx <- Kdist$id
Kdist_D <- exp(-Kdist$dist)
A <- matrix(0, nrow=nrow(proj), ncol=nrow(proj))
for(i in 1:nrow(proj)) #add neighbours of point i
    A[i, Kdist_idx[i,]] <- Kdist_D[i,]
for(i in 1:nrow(proj)) #add distances having i in neighbourhood
    A[i, -Kdist_idx[i,]] <- A[ -Kdist_idx[i,], i]
```

- The adjacency matrix describes the data/graph edges and distances. Now we build the Laplacian matrix, which is $D-A$, with D a diagonal with the sums of each row of A. The spectrum of L - after some normalization - describes how the graph can be cut in connected components.

- One of the possible normalizations of L is given by $D^{-1/2}LD^{1/2}$, which renders the laplacian symmetric (be careful of the zeros in D). Once you have done this,

- calculate the SVD of the normalized L, from which you need the eigenvector matrix U. Select it with the first $k$ columns, where $k$ is the number of clusters you want. This matrix represents a projection of your data where points connected in the graph are well connected.

- take the last k columns of U (starting from the last one and backwards), and normalize them so they sum to one.

- apply any clustering you prefere to the normalized matrix you extracted from U.

- Try different numbers of neighbors or different kernels to make the graph more or less connected and see what happens
