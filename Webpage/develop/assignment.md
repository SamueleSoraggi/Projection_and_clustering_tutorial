# Projection exercise

First of all, copy the code for the exercise from the book. You can copy it also here from the section `Code-->Book code`. 

## assignment

Depending on your coding skills, you can decide how much you want to do for the assignment. Also fiddling with the Iris tutorial and trying out things can be ok :)

Choose a dataset or work on the Iris data. Various datasets are present in the folder `Data` of this github repository [link here](hello), or you can type the function `data()` in R to open one of many datasets, such as `data(decathlon)`, `data(iris)` or `data(Cars1993)`. The data has various columns, keep only the numeric ones and eventual variables with labels if they are present.

Then:

- Try to run various projection methods as with the iris data. You can reuse the code from `Code-->Iris example`. Fiddle around and try some parameters, use the help functions to see the documentation, for example `help(PCA)`.

- See if your data shows some patterns in your projections. Do you have any outliers? Are there some clear separations into categories?

- Try to implement one or more improvements as in the slides:
  - early exaggeration
  - initialization with PCA or other projections
  - momentum addition to gradient descent
  - faster calculation of affinities in low dimension avoiding for loop

- compare new and old functions with `microbenchmark` as in the example notebook.
