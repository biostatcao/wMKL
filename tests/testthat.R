Sys.setenv("R_TESTS" = "")

library(testthat)
library(wMLR)

test_check("wMLR")
