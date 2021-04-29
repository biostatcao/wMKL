#' estimate the number of clusters by means of two huristics as discussed in the CIMLR paper
#'
#' @title CIMLR.weight Estimate Number of Clusters
#'
#' @examples
#' CIMLR_Estimate_Number_of_Clusters_weight(exampledata$PRCCReduced_X,
#'    NUMC = 2:5,
#'    cores.ratio = 0,weight=exampledata$weightforfeatures)
#'
#' @param all_data is a list of multi-omic data each of which is an (n x m) data matrix of measurements of cancer patients
#' @param NUMC vector of number of clusters to be considered
#' @param cores.ratio ratio of the number of cores to be used when computing the multi-kernel
#' @param weight a list of weight for multi-omic data, each of which is an m dimensional vector
#'
#' @return a list of 2 elements: K1 and K2 with an estimation of the best clusters (the lower
#' values the better) as discussed in the original paper of SIMLR
#'
#' @export CIMLR_Estimate_Number_of_Clusters_weight
#' @importFrom parallel stopCluster makeCluster detectCores clusterEvalQ parLapply
#' @importFrom stats dnorm kmeans pbeta rnorm
#' @importFrom methods is
#' @import Matrix
#'
#'

"CIMLR_Estimate_Number_of_Clusters_weight"= function( all_data, NUMC = 2:5, cores.ratio = 0,weight ) {

    for(data_types in 1:length(all_data)) {

        X = all_data[[data_types]]

        curr_X = all_data[[data_types]]
        curr_weight = weight[[data_types]]
        if(data_types==1) {

            D_Kernels = multiple.kernel.cimlr.weight(t(curr_X),cores.ratio,curr_weight )
            distX = array(0,c(dim(D_Kernels[[1]])[1],dim(D_Kernels[[1]])[2]))
            for (i in 1:length(D_Kernels)) {
                distX = distX + D_Kernels[[i]]
            }
            distX = distX / length(D_Kernels)
            W =  max(max(distX)) - distX
            W = network.diffusion.numc(W,max(ceiling(ncol(X)/20),10))

        }
        else {

            D_Kernels = c(D_Kernels,multiple.kernel.cimlr.weight(t(curr_X),cores.ratio,curr_weight ))
            distX = array(0,c(dim(D_Kernels[[1]])[1],dim(D_Kernels[[1]])[2]))
            for (i in 1:length(D_Kernels)) {
                distX = distX + D_Kernels[[i]]
            }
            distX = distX / length(D_Kernels)
            W0 =  max(max(distX)) - distX
            W = W + network.diffusion.numc(W0,max(ceiling(ncol(X)/20),10))

        }

    }

    Quality = Estimate_Number_of_Clusters_given_graph(W,NUMC)
    Quality_plus = Estimate_Number_of_Clusters_given_graph(W,NUMC+1)
    Quality_minus = Estimate_Number_of_Clusters_given_graph(W,NUMC-1)

    K1 = 2*(1 + Quality) - (2 + Quality_plus + Quality_minus)
    K2 = K1*(NUMC+1)/(NUMC)

    return(list(K1=K1,K2=K2))

}


