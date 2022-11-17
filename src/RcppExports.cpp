// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// Rtsne_cpp
Rcpp::List Rtsne_cpp(NumericVector I, NumericVector J, NumericVector V, int no_dims_in, double perplexity_in, double theta_in, bool verbose, int max_iter, NumericMatrix Y_in, bool init);
RcppExport SEXP _wMKL_Rtsne_cpp(SEXP ISEXP, SEXP JSEXP, SEXP VSEXP, SEXP no_dims_inSEXP, SEXP perplexity_inSEXP, SEXP theta_inSEXP, SEXP verboseSEXP, SEXP max_iterSEXP, SEXP Y_inSEXP, SEXP initSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type I(ISEXP);
    Rcpp::traits::input_parameter< NumericVector >::type J(JSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type V(VSEXP);
    Rcpp::traits::input_parameter< int >::type no_dims_in(no_dims_inSEXP);
    Rcpp::traits::input_parameter< double >::type perplexity_in(perplexity_inSEXP);
    Rcpp::traits::input_parameter< double >::type theta_in(theta_inSEXP);
    Rcpp::traits::input_parameter< bool >::type verbose(verboseSEXP);
    Rcpp::traits::input_parameter< int >::type max_iter(max_iterSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type Y_in(Y_inSEXP);
    Rcpp::traits::input_parameter< bool >::type init(initSEXP);
    rcpp_result_gen = Rcpp::wrap(Rtsne_cpp(I, J, V, no_dims_in, perplexity_in, theta_in, verbose, max_iter, Y_in, init));
    return rcpp_result_gen;
END_RCPP
}

RcppExport SEXP projsplx(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"_wMKL_Rtsne_cpp", (DL_FUNC) &_wMKL_Rtsne_cpp, 10},
    {"projsplx", (DL_FUNC) &projsplx, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_wMKL(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
