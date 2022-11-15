# Projection exercise


## assignment

**Depending on your coding skills**, you can decide how much you want to do for the assignment. Also fiddling with a tutorial and trying out things can be ok :) To run one of the tutorials, you need to download the file `functions.R` in the folder `Code` of the repository ([click here](https://github.com/SamueleSoraggi/Projection_and_clustering_tutorial/blob/main/Code/functions.R)). Put the file inside the same folder where you are coding. This file contains also the solution to the exercise, so you can compare how you try to solve the assignment and how I did it (but don't cheat!).

1) Choose a dataset or work on one of the examples you can find in the menu under `Code`. Various datasets are present in the folder `Data` of this github repository ([link here](https://github.com/SamueleSoraggi/Projection_and_clustering_tutorial/tree/main/Data)), or you can type the function `data()` in R to open one of many datasets, such as `data(decathlon)`, `data(iris)` or `data(Cars93)`. I documented the data under the `Datasets` menu.

2) Feel free to Copy-paste the code for the exercise from the book, so that you define the functions for tSNE. You can copy the code also here from the section `Code-->Book code`. Alternatively, download and source the file [`functions.R`](https://github.com/SamueleSoraggi/Projection_and_clustering_tutorial/blob/main/Code/functions.R) into your code.

Then:

- Try to run various projection methods as in the tutorials. You can reuse any of the tutorials to reuse some code. 

- Try some optional parameters in kernel PCA, tSNE and UMAP. See how the perplexity and learning rate `rho` of tSNE are influential in the result. Use the help to see the documentation of a function, for example `help(PCA)`.

- Does your data shows some patterns in your projections? Do you have any outliers? Are there some clear separations into categories?

- Try to implement one or more improvements, here listed in order of difficulty of implementation:
  - faster calculation of affinities `Pji` in low dimension, avoiding the nested for loops
  - early stop criteria on the KL divergence
  - early exaggeration 
  - momentum addition to gradient descent

- Every time you improve your function, compare new and old code with `microbenchmark` as in the example notebooks. To do this, copy the book functions and give them a new name. If you do that in the file `functions.R`, benchmark also against the `sam_tsne` function.
