rm(list=ls())

library(Rcpp)
library(inline)


inc = '
#include <blitz/array.h>
'

src = '
using namespace blitz;
Rcpp::NumericVector A(A_);
Rcpp::NumericVector A2(A2_);
// return objects
Rcpp::NumericVector Vout(V_);
//Rcpp::IntegerVector Dout(D_);

// read dimension attribute of R arrays
Rcpp::IntegerVector d1 = A.attr("dim");
Rcpp::IntegerVector d2 = A2.attr("dim");

// create 2 blitz cubes B1 and B2
// supply contents of dim vectors manually
blitz::Array<double,3> B1(A.begin(), shape(d1(0),d1(1),d1(2)), neverDeleteData);
blitz::Array<double,3> B2(A2.begin(), shape(d2(0),d2(1),d2(2)), neverDeleteData);

//define indices
firstIndex i1;
secondIndex i2;
thirdIndex i3;

// create to value functions to store values after maximizing
// over the third dimension of B1 and B2
blitz::Array<double,2> V1(blitz::Range(0,d1(0)),blitz::Range(0,d1(1)));
blitz::Array<double,2> V2(blitz::Range(0,d1(0)),blitz::Range(0,d1(1)));

// maximize over i3
V1 = max(B1,i3);
V2 = max(B2,i3);



// map as blitz arrays
blitz::Array<double,2> Vmax(Vout.begin(), shape(d1(0),d1(1)), neverDeleteData);
//blitz::Array<double,2> Dmax(Dout.begin(), shape(d2(0),d2(1)), neverDeleteData);

Vmax = where(V1 > V2, V1, V2);
//Dmax = where(V1 > V1, 1, 2);

Rcout << Vmax << std::endl;

// copy to NumericVectors
Vout = Vmax;
//Dout = Dmax;

//Rcpp::List list = Rcpp::List::create( _["vmax"] = Vout, _["dchoice"] = Dout);
Rcpp::List list = Rcpp::List::create( _["vmax"] = Vout);
'

A = array(1:60,c(2,5,6))
A2 = array(120:60,c(2,5,6))
V = array(0,c(2,5))

#f2 = cxxfunction(signature(A_="numeric",A2_="numeric",V_="numeric",D_="numeric"),body=src,plugin="Rcpp",includes=inc)
f2 = cxxfunction(signature(A_="numeric",A2_="numeric",V_="numeric"),body=src,plugin="Rcpp",includes=inc)
result = f2(A,A2,V)
