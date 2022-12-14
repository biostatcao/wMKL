% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CIMLR_Estimate_Number_of_Clusters_weight.R
\name{CIMLR_Estimate_Number_of_Clusters_weight}
\alias{CIMLR_Estimate_Number_of_Clusters_weight}
\title{CIMLR.weight Estimate Number of Clusters}
\usage{
CIMLR_Estimate_Number_of_Clusters_weight(
  all_data,
  NUMC = 2:5,
  cores.ratio = 0,
  weight
)
}
\arguments{
\item{all_data}{is a list of multi-omic data each of which is an (n x m) data matrix of measurements of cancer patients}

\item{NUMC}{vector of number of clusters to be considered}

\item{cores.ratio}{ratio of the number of cores to be used when computing the multi-kernel}

\item{weight}{a list of weight for multi-omic data, each of which is an m dimensional vector}
}
\value{
a list of 2 elements: K1 and K2 with an estimation of the best clusters (the lower
values the better) as discussed in the original paper of SIMLR
}
\description{
estimate the number of clusters by means of two huristics as discussed in the CIMLR paper
}
\examples{
CIMLR_Estimate_Number_of_Clusters_weight(exampledata$PRCCReduced_X,
   NUMC = 2:5,
   cores.ratio = 0,weight=exampledata$weightforfeatures)

}
