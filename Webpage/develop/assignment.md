# Projection exercise


## assignment

Depending on your coding skills, you can decide how much you want to do for the assignment. Also fiddling with the Iris tutorial and trying out things can be ok :)

Choose a dataset or work on one of the examples you can find in the menu under `Code`. Various datasets are present in the folder `Data` of this github repository ([link here](https://github.com/SamueleSoraggi/Projection_and_clustering_tutorial/tree/main/Data)), or you can type the function `data()` in R to open one of many datasets, such as `data(decathlon)`, `data(iris)` or `data(Cars93)`. The data has various columns, keep only the numeric ones and eventual variables with labels if they are present.


Copy-paste the code for the exercise from the book, so that you define the functions for tSNE. You can copy the code also here from the section `Code-->Book code`. 

Then:

- Try to run various projection methods as with the iris data. You can reuse the code from `Code-->Iris example` (note that there I import the file `functions.R`). Fiddle around and try some parameters, use the help functions to see the documentation, for example `help(PCA)`.

- See if your data shows some patterns in your projections. Do you have any outliers? Are there some clear separations into categories?

- Try to implement one or more improvements as in the slides:
  - early exaggeration
  - initialization with PCA or other projections
  - momentum addition to gradient descent
  - faster calculation of affinities in low dimension avoiding for loop

- compare new and old functions with `microbenchmark` as in the example notebook.
