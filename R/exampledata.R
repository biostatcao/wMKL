#' @name exampledata
#' @title test dataset for wMKL
#' @description example dataset to test wMKL. This is a reduced version of the dataset papillary renal cell carcinoma (PRCC)
#'              in wMKL: a weighted multi-kernel learning model paper.
#' @docType data
#' @usage data(exampledata)
#' @format multi-omic data of cancer patients
#' @return list of 4 element:
#'		PRCCReduced_X  = input dataset as a list of 3 (reduced) multi-omic data each of which is an (n x m) measurements of cancer patients
#'		p1_features and p2_features are two types of p-values
#'    weightforfeatures=input dataset as a list of 3 (reduced) weight for multi-omic data each of which is an m measurements of features
NULL
