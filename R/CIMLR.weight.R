#' perform the CIMLR.weight clustering algorithm
#'
#' @title CIMLR.weight
#'
#' @examples
#' CIMLR.weight(X =exampledata$PRCCReduced_X, c = 3,
#'              cores.ratio = 0,weight=exampledata$weightforfeatures)
#'
#' @param X a list of multi-omic data each of which is an (n x m) data matrix of measurements of cancer patients
#' @param c number of clusters to be estimated over X
#' @param no.dim number of dimensions
#' @param k tuning parameter
#' @param cores.ratio ratio of the number of cores to be used when computing the multi-kernel
#' @param weight a list of weight for multi-omic data, each of which is an m dimensional vector
#'
#' @return clusters the patients based on CIMLR.weight and their similarities

#' @return list of 8 elements describing the clusters obtained by CIMLR, of which y are the resulting clusters:
#'      y = results of k-means clusterings,
#'      y_spectral=results of spectral clustering,
#'      S = similarities computed by CIMLR,
#'      F = results from tsne(S),
#'      ydata = data referring the the results by k-means,
#'      alphaK = clustering coefficients,
#'      execution.time = execution time of the present run,
#'      converge = iterative convergence values by T-SNE,
#'      LF = parameters of the clustering
#'
#' @export CIMLR.weight
#' @importFrom parallel stopCluster makeCluster detectCores clusterEvalQ
#' @importFrom parallel parLapply
#' @importFrom stats dnorm kmeans pbeta rnorm
#' @importFrom methods is
#' @import Matrix
#' @useDynLib wMKL projsplx
#'

#####################################################################################
#   define the CIMLR.weight function, revise diff,and change the hecanshu#
#####################################################################################
"CIMLR.weight"<- function( X, c, no.dim = NA, k = 10, cores.ratio = 0 ,weight) {

    # set any required parameter to the defaults
    if(is.na(no.dim)) {
        no.dim = c
    }

    # start the clock to measure the execution time
    ptm = proc.time()

    # set some parameters
    NITER = 30
    num = ncol(X[[1]])
    r = -1
    beta = 0.8

    cat("Computing the multiple Kernels.\n")

    # compute the kernels
    for(data_types in 1:length(X)) {
        curr_X = X[[data_types]]
        curr_weight = weight[[data_types]]
        if(data_types==1) {
            D_Kernels = multiple.kernel.cimlr.weight(t(curr_X),cores.ratio,curr_weight )
        }
        else {
            D_Kernels = c(D_Kernels, multiple.kernel.cimlr.weight(t(curr_X),cores.ratio,curr_weight))
        }
    }

    # set up some parameters
    alphaK = 1 / rep(length(D_Kernels),length(D_Kernels))
    distX = array(0,c(dim(D_Kernels[[1]])[1],dim(D_Kernels[[1]])[2]))
    for (i in 1:length(D_Kernels)) {
        distX = distX + D_Kernels[[i]]
    }
    distX = distX / length(D_Kernels)

    # sort distX for rows
    res = apply(distX,MARGIN=1,FUN=function(x) return(sort(x,index.return = TRUE)))
    distX1 = array(0,c(nrow(distX),ncol(distX)))
    idx = array(0,c(nrow(distX),ncol(distX)))
    for(i in 1:nrow(distX)) {
        distX1[i,] = res[[i]]$x
        idx[i,] = res[[i]]$ix
    }

    A = array(0,c(num,num))
    di = distX1[,2:(k+2)]
    rr = 0.5 * (k * di[,k+1] - apply(di[,1:k],MARGIN=1,FUN=sum))
    id = idx[,2:(k+2)]

    numerator = (apply(array(0,c(length(di[,k+1]),dim(di)[2])),MARGIN=2,FUN=function(x) {x=di[,k+1]}) - di)
    temp = (k*di[,k+1] - apply(di[,1:k],MARGIN=1,FUN=sum) + .Machine$double.eps)
    denominator = apply(array(0,c(length(temp),dim(di)[2])),MARGIN=2,FUN=function(x) {x=temp})
    temp = numerator / denominator
    a = apply(array(0,c(length(t(1:num)),dim(di)[2])),MARGIN=2,FUN=function(x) {x=1:num})
    A[cbind(as.vector(a),as.vector(id))] = as.vector(temp)
    if(r<=0) {
        r = mean(rr)
    }
    lambda = max(mean(rr),0)
    A[is.nan(A)] = 0
    S0 = max(max(distX)) - distX

    cat("Performing network diffusion.\n")

    # perform network diffusion
    S0 = network.diffusion(S0,k)

    # compute dn
    S0 = dn.cimlr(S0,'ave')
    S = (S0 + t(S0)) / 2
    D0 = diag(apply(S,MARGIN=2,FUN=sum))
    L0 = D0 - S

    eig1_res = eig1(L0,c,0)
    F_eig1 = eig1_res$eigvec
    temp_eig1 = eig1_res$eigval
    evs_eig1 = eig1_res$eigval_full

    F_eig1 = dn.cimlr(F_eig1,'ave')

    # perform the iterative procedure NITER times
    converge = vector()
    for(iter in 1:NITER) {

        cat("Iteration: ",iter,"\n")

        distf = L2_distance_1(t(F_eig1),t(F_eig1))
        A = array(0,c(num,num))
        b = idx[,2:dim(idx)[2]]
        a = apply(array(0,c(num,ncol(b))),MARGIN=2,FUN=function(x){ x = 1:num })
        inda = cbind(as.vector(a),as.vector(b))
        ad = (distX[inda]+lambda*distf[inda])/2/r
        dim(ad) = c(num,ncol(b))

        # call the c function for the optimization
        c_input = -t(ad)
        c_output = t(ad)
        ad = t(.Call("projsplx", c_input, c_output))

        A[inda] = as.vector(ad)
        A[is.nan(A)] = 0
        S = (1 - beta) * A + beta * S
        S = network.diffusion(S,k)
        S = (S + t(S)) / 2
        D = diag(apply(S,MARGIN=2,FUN=sum))
        L = D - S
        F_old = F_eig1
        eig1_res = eig1(L,c,0)
        F_eig1 = eig1_res$eigvec
        temp_eig1 = eig1_res$eigval
        ev_eig1 = eig1_res$eigval_full
        F_eig1 = dn.cimlr(F_eig1,'ave')
        F_eig1 = (1 - beta) * F_old + beta * F_eig1
        evs_eig1 = cbind(evs_eig1,ev_eig1)
        DD = vector()
        for (i in 1:length(D_Kernels)) {
            temp = (.Machine$double.eps+D_Kernels[[i]]) * (S+.Machine$double.eps)
            DD[i] = mean(apply(temp,MARGIN=2,FUN=sum))
        }
        alphaK0 = umkl.cimlr(DD)
        alphaK0 = alphaK0 / sum(alphaK0)
        alphaK = (1-beta) * alphaK + beta * alphaK0
        alphaK = alphaK / sum(alphaK)
        fn1 = sum(ev_eig1[1:c])
        fn2 = sum(ev_eig1[1:(c+1)])
        converge[iter] = fn2 - fn1
        if (iter<10) {
            if (ev_eig1[length(ev_eig1)] > 0.000001) {
                lambda = 1.5 * lambda
                r = r / 1.01
            }
        }
        else {
            if(converge[iter]>1.01*converge[iter-1]) {
                S = S_old
                if(converge[iter-1] > 0.2) {
                    warning('Maybe you should set a larger value of c.')
                }
                break
            }
        }
        S_old = S

        # compute Kbeta
        distX = D_Kernels[[1]] * alphaK[1]
        for (i in 2:length(D_Kernels)) {
            distX = distX + as.matrix(D_Kernels[[i]]) * alphaK[i]
        }

        # sort distX for rows
        res = apply(distX,MARGIN=1,FUN=function(x) return(sort(x,index.return = TRUE)))
        distX1 = array(0,c(nrow(distX),ncol(distX)))
        idx = array(0,c(nrow(distX),ncol(distX)))
        for(i in 1:nrow(distX)) {
            distX1[i,] = res[[i]]$x
            idx[i,] = res[[i]]$ix
        }

    }
    LF = F_eig1
    D = diag(apply(S,MARGIN=2,FUN=sum))
    L = D - S

    # compute the eigenvalues and eigenvectors of P
    eigen_L = eigen(L)
    U = eigen_L$vectors
    D = eigen_L$values

    if (length(no.dim)==1) {
        U_index = seq(ncol(U),(ncol(U)-no.dim+1))
        F_last = tsne(S,k=no.dim,initial_config=U[,U_index])
    }
    else {
        F_last = list()
        for (i in 1:length(no.dim)) {
            U_index = seq(ncol(U),(ncol(U)-no.dim[i]+1))
            F_last[i] = list(tsne(S,k=no.dim[i],initial_config=U[,U_index]))
        }
    }

    # compute the execution time
    execution.time = proc.time() - ptm

    cat("Performing Kmeans.\n")
    y = kmeans(F_last,c,nstart=200)

    ydata = tsne(S)

    #compute the spectral clustering results,spectralClustering() from snftool
    y_spectral=spectralClustering(S,c)


    # create the structure with the results
    results = list()
    results[["y"]] = y
    results[["y_spectral"]] = y_spectral
    results[["S"]] = S
    results[["F"]] = F_last
    results[["ydata"]] = ydata
    results[["alphaK"]] = alphaK
    results[["execution.time"]] = execution.time
    results[["converge"]] = converge
    results[["LF"]] = LF

    return(results)

}





