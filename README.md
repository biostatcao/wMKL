
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wMLR

<!-- badges: start -->
<!-- badges: end -->

We develop a novel unified method, prior weight-boosted Multikernel
LeaRning (wMLR), under the CIMLR framework.The goal of wMLR is to
incorporate heterogenous data types as well as flexible weight functions
to boost subtype identification, providing a generic weighted modeling
method. An important feature of wMLR is that it allows for incorporation
of flexible weight functions to boost subtype identification. In our
study, we consider features that can better differentiate tumor samples
from adjacent normal samples (or independent normal samples) as
potential signal features, weighting the feature using the feature-level
association P-value from paired t-test (or the two-sample t-test). Users
can define other types of weight functions. For example, with the
interest of survival outcomes, we could use the survival outcome guided
weights, such as log-hazard ratio (logHR) estimated from univariable Cox
regression. We provide spectral clustering results in CIMLR function,
which is robust than the k-means results in the original CIMLR package.
For the weighted function, we keep the form similar as the CIMLR
package.

## Installation

The R version of *wMLR* can be installed from Github. To do so, we need
to install the R packages *wMLR* depends on and the devtools package.

First we run an R session and we execute the following commands.

``` r
# run this commands only if the following R packages are not already installed
install.packages("devtools", dependencies = TRUE)
install.packages("Matrix", dependencies = TRUE)
```

Now we can install and run *wMLR* as follows:

``` r
# install wMLR from Github
library("devtools")
devtools::install_github("biostatcao/wMLR")

# load wMLR library
library("wMLR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(wMLR)
## basic example code

data(exampledata)

#CIMLR.weight Estimate Number of Clusters
num_results=CIMLR_Estimate_Number_of_Clusters_weight(exampledata$PRCCReduced_X,
             NUMC = 2:5,
             cores.ratio = 0,weight=exampledata$weightforfeatures)

Estimate_num=which.min(num_results$K1)+1

#perform the CIMLR.weight clustering algorithm
cluster_results=CIMLR.weight(X =exampledata$PRCCReduced_X, c = 3,
                cores.ratio = 0,weight=exampledata$weightforfeatures)
#> Computing the multiple Kernels.
#> Performing network diffusion.
#> Iteration:  1 
#> Iteration:  2 
#> Iteration:  3 
#> Iteration:  4 
#> Iteration:  5 
#> Iteration:  6 
#> Iteration:  7 
#> Iteration:  8 
#> Iteration:  9 
#> Iteration:  10
#> Warning in CIMLR.weight(X = exampledata$PRCCReduced_X, c = 3, cores.ratio = 0, :
#> Maybe you should set a larger value of c.
#> Performing t-SNE.
#> Epoch: Iteration # 100  error is:  0.6181965 
#> Epoch: Iteration # 200  error is:  0.2384324 
#> Epoch: Iteration # 300  error is:  0.227997 
#> Epoch: Iteration # 400  error is:  0.2213854 
#> Epoch: Iteration # 500  error is:  0.2145941 
#> Epoch: Iteration # 600  error is:  0.4344568 
#> Epoch: Iteration # 700  error is:  0.2186193 
#> Epoch: Iteration # 800  error is:  0.2120475 
#> Epoch: Iteration # 900  error is:  0.4437871 
#> Epoch: Iteration # 1000  error is:  0.2637841 
#> Performing Kmeans.
#> Performing t-SNE.
#> Epoch: Iteration # 100  error is:  19.60953 
#> Epoch: Iteration # 200  error is:  2.020666 
#> Epoch: Iteration # 300  error is:  1.195906 
#> Epoch: Iteration # 400  error is:  1.667592 
#> Epoch: Iteration # 500  error is:  0.5703454 
#> Epoch: Iteration # 600  error is:  0.4066862 
#> Epoch: Iteration # 700  error is:  0.3985428 
#> Epoch: Iteration # 800  error is:  0.4639896 
#> Epoch: Iteration # 900  error is:  0.8858816 
#> Epoch: Iteration # 1000  error is:  2.26323

cluster_results$y_spectral  # the spectral clustering based clustering results
#>  [1] 3 3 2 3 3 3 2 3 3 3 1 3 1 3 1 1 1 1 2 3 3 3 3 1 1 3 1 3 3 3 3 2 1 2 3 2 3 1
#> [39] 1 2 1 2 3 2 2 3 1 3 3 2
```

**DEBUG**

Please feel free to contact us if you have problems running our tool at
<caohy@sxmu.edu.cn> or <cuiy@msu.edu>.
