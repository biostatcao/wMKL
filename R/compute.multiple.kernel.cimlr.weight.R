#########################################################################
# define the weighted multiple.kernel.cimlr.weight,
# I revised the Diff function and change the sigma = seq(2,1,-0.25)     #
# to sigma = seq(2,0.1,length.out=5)
#########################################################################

multiple.kernel.cimlr.weight= function( x, cores.ratio = 0 ,weight) {

    # set the parameters
    kernel.type = list()
    kernel.type[1] = list("poly")
    kernel.params = list()
    kernel.params[1] = list(0)

    # compute some parameters from the kernels
    N = dim(x)[1]
    KK = 0
    sigma = seq(2,1,-0.25)

    #####################################
    # I changed he diff as ^(1/2)       #
    ####################################

    # compute and sort Diff
    Diff = (dist2.cimlr.weight(x,weight))^(1/2)
    Diff_sort = t(apply(Diff,MARGIN=2,FUN=sort))

    # compute the combined kernels
    m = dim(Diff)[1]
    n = dim(Diff)[2]
    allk = seq(10,30,2)


    # setup a parallelized estimation of the kernels
    cores = as.integer(cores.ratio * (detectCores() - 1))
    if (cores < 1 || is.na(cores) || is.null(cores)) {
        cores = 1
    }

    cl = makeCluster(cores)

    clusterEvalQ(cl, {library(Matrix)})

    D_Kernels = list()
    D_Kernels = unlist(parLapply(cl,1:length(allk),fun=function(l,x_fun=x,Diff_sort_fun=Diff_sort,allk_fun=allk,
                                                                Diff_fun=Diff,sigma_fun=sigma,KK_fun=KK) {
        if(allk_fun[l]<(nrow(x_fun)-1)) {
            TT = apply(Diff_sort_fun[,2:(allk_fun[l]+1)],MARGIN=1,FUN=mean) + .Machine$double.eps
            TT = matrix(data = TT, nrow = length(TT), ncol = 1)
            Sig = apply(array(0,c(nrow(TT),ncol(TT))),MARGIN=1,FUN=function(x) {x=TT[,1]})
            Sig = Sig + t(Sig)
            Sig = Sig / 2
            Sig_valid = array(0,c(nrow(Sig),ncol(Sig)))
            Sig_valid[which(Sig > .Machine$double.eps,arr.ind=TRUE)] = 1
            Sig = Sig * Sig_valid + .Machine$double.eps
            for (j in 1:length(sigma_fun)) {
                W = dnorm(Diff_fun,0,sigma_fun[j]*Sig)
                D_Kernels[[KK_fun+l+j]] = Matrix((W + t(W)) / 2, sparse=TRUE, doDiag=FALSE)
            }
            return(D_Kernels)
        }
    }))

    stopCluster(cl)

    # compute D_Kernels
    for (i in 1:length(D_Kernels)) {
        K = D_Kernels[[i]]
        k = 1/sqrt(diag(K)+1)
        G = K * (k %*% t(k))
        G1 = apply(array(0,c(length(diag(G)),length(diag(G)))),MARGIN=2,FUN=function(x) {x=diag(G)})
        G2 = t(G1)
        D_Kernels_tmp = (G1 + G2 - 2*G)/2
        D_Kernels_tmp = D_Kernels_tmp - diag(diag(D_Kernels_tmp))
        D_Kernels[[i]] = Matrix(D_Kernels_tmp, sparse=TRUE, doDiag=FALSE)
    }

    return(D_Kernels)

}

#######################################
# define the weighted distance        #
#######################################
# compute the single kernel
dist2.cimlr.weight= function( x,weight) {

    # weighted for x
    y=t(t(x) * sqrt(weight))
    dist = dist2.cimlr(y)
    return(dist)
}
