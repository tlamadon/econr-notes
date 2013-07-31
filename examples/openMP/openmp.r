#!/usr/bin/r

library(inline)
library(rbenchmark)

## same, but with Rcpp vector just to see if there is measurable difference
serialRcppCode <- '
   // assign to C++ vector
   std::vector<double> x = Rcpp::as<std::vector< double > >(xs);
   size_t n = x.size();

   for (size_t i=0; i<n; i++) {
     double ss=0,si=0;
     for (int n2=0; n2<1000; n2++) {
        si =si+1;
        ss += 1/si;
     }
     x[i] = ss;
   }
   return Rcpp::wrap(x);
'
funSerialRcpp <- cxxfunction(signature(xs="numeric"), body=serialRcppCode, plugin="Rcpp")

## lastly via OpenMP for parallel use
openMPCode <- '
   // assign to C++ vector
   std::vector<double> x = Rcpp::as<std::vector< double > >(xs);
   size_t n = x.size();

   #pragma omp parallel for shared(x, n)
   for (size_t i=0; i<n; i++) {
     double ss=0,si=0;
     for (int n2=0; n2<1000; n2++) {
        si =si+1;
        ss += 1/si;
     }
     x[i] = ss;
   }
   return Rcpp::wrap(x);
'

## modify the plugin for Rcpp to support OpenMP
settings <- getPlugin("Rcpp")
settings$env$PKG_CXXFLAGS <- paste('-fopenmp', settings$env$PKG_CXXFLAGS)
settings$env$PKG_LIBS <- paste('-fopenmp -lgomp', settings$env$PKG_LIBS)

funOpenMP <- cxxfunction(signature(xs="numeric"), body=openMPCode, plugin="Rcpp", settings=settings)


z <- seq(1, 2e5)
res <- benchmark(funSerialRcpp(z), funOpenMP(z),
                 columns=c("test", "replications", "elapsed",
                           "relative", "user.self", "sys.self"),
                 order="relative",
                 replications=100)
print(res)
