wmkl = CIMLR.weight(X =exampledata$PRCCReduced_X, c = 3,
                     cores.ratio = 0,weight=exampledata$weightforfeatures)

context("wMKL")
test_that("structure of output is compliant", {
    expect_equal(names(wmkl), c("y","y_spectral", "S", "F", "ydata",
        "alphaK", "execution.time", "converge", "LF"))
})


