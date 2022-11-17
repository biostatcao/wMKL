Sys.setenv("R_TESTS" = "")

library(testthat)
library(wMKL)

test_check("wMKL")
