
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wMKL

<!-- badges: start -->
<!-- badges: end -->

    We develop a weighted method, termed as prior-weight-boosted Multi-Kernel Learning (wMKL) 
    which can incorporate heterogenous data types as well as flexible weight functions, 
    to boost subtype identification. Given a series of weight functions, 
    we propose an omnibus combination strategy to integrate different weight related p-values. 
    The integrated p-values for features are then applied to update the weighted similarity kernel. 
    The signal related outcomes can be normal vs tumor tissues, treatment responses, 
    survival outcomes and other clinical and histopathological characters. 
    Here, we specifically focus on features that can better differentiate between normal vs tumor tissues (use paired or two-sample t-test depending on the samples collected), 
    and on pathological stage-driven features with relevance to survival (use Kruskal-Wallis H-test). 
    The two types of p-values obtained for each feature are then integrated with a Cauchy combination method to get an aggregated p-value for each feature.  
    We provide spectral clustering results in CIMLR function, which is robust than the k-means results in the original CIMLR package.
    For the weighted function, we keep the form similar as the CIMLR package.

## Installation

The R version of *wMKL* can be installed from Github. To do so, we need
to install the R packages *wMKL* depends on and the devtools package.

First we run an R session and we execute the following commands.

``` r
# run this commands only if the following R packages are not already installed
install.packages("devtools", dependencies = TRUE)
install.packages("Matrix", dependencies = TRUE)
```

Now we can install and run *wMKL* as follows:

``` r
# install wMKL from Github
library("devtools")
devtools::install_github("biostatcao/wMKL")

# load wMKL library
library("wMKL")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(wMKL)
## basic example code

data(exampledata)

#Calculate weight for each feature. The signal related outcomes can be normal vs tumor tissues, treatment responses, survival outcomes and other clinical and histopathological characters. 
#Two types of p-values are provided in the exampledata for each feature,Cauchy combination method is used to get an aggregated p-value for each feature.    

#Cauchy combination
ACAT_function=function(y){
  1-pcauchy(sum((1/length(y))*tan((0.5-y)*pi)))
}

p12_miRNA=cbind(exampledata$p1_features$p1_miRNA,exampledata$p2_features$p2_miRNA)
pcauchy_miRNA=apply(p12_miRNA,1,ACAT_function)

p12_mRNA=cbind(exampledata$p1_features$p1_mRNA,exampledata$p2_features$p2_mRNA)
pcauchy_mRNA=apply(p12_mRNA,1,ACAT_function)

p12_methy=cbind(exampledata$p1_features$p1_methy,exampledata$p2_features$p2_methy)
pcauchy_methy=apply(p12_methy,1,ACAT_function)

weight_miRNA_cauchy=-log10(pcauchy_miRNA)/sum(-log10(pcauchy_miRNA))
weight_mRNA_cauchy=-log10(pcauchy_mRNA)/sum(-log10(pcauchy_mRNA))
weight_methy_cauchy=-log10(pcauchy_methy)/sum(-log10(pcauchy_methy))
weightforfeatures=list(weight_miRNA=weight_miRNA_cauchy,
                       weight_mRNA=weight_mRNA_cauchy,
                       weight_methylation=weight_methy_cauchy)


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
#> Performing t-SNE.
#> Epoch: Iteration # 100  error is:  0.5924967 
#> Epoch: Iteration # 200  error is:  0.2707347 
#> Epoch: Iteration # 300  error is:  0.2890757 
#> Epoch: Iteration # 400  error is:  0.1057449 
#> Epoch: Iteration # 500  error is:  0.1084295 
#> Epoch: Iteration # 600  error is:  0.5714641 
#> Epoch: Iteration # 700  error is:  0.0979835 
#> Epoch: Iteration # 800  error is:  0.2472839 
#> Epoch: Iteration # 900  error is:  0.4002461 
#> Epoch: Iteration # 1000  error is:  0.2746229 
#> Performing Kmeans.
#> Performing t-SNE.
#> Epoch: Iteration # 100  error is:  22.229 
#> Epoch: Iteration # 200  error is:  4.839887 
#> Epoch: Iteration # 300  error is:  1.281601 
#> Epoch: Iteration # 400  error is:  0.5460376 
#> Epoch: Iteration # 500  error is:  3.82911 
#> Epoch: Iteration # 600  error is:  1.089239 
#> Epoch: Iteration # 700  error is:  0.8038316 
#> Epoch: Iteration # 800  error is:  3.193441 
#> Epoch: Iteration # 900  error is:  1.012403 
#> Epoch: Iteration # 1000  error is:  0.7421243

cluster_results$y_spectral  # the spectral clustering based clustering results
#>  [1] 1 3 3 2 2 3 3 2 3 2 3 1 1 2 3 3 3 3 3 3 3 3 1 3 1 2 3 3 2 2 2 1 3 1 3 1 2 3
#> [39] 3 3 3 1 3 3 1 3 1 1 2 1
```

**DEBUG**

Please feel free to contact us if you have problems running our tool at
<caohy@sxmu.edu.cn>.
