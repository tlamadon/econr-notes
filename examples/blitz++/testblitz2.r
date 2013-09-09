rm(list=ls())

library(Rcpp)
library(inline)


inc = '
#include <blitz/array.h>
'

src = '
using namespace blitz;
// in objects
Rcpp::NumericVector A(A_);
Rcpp::NumericVector A2(A2_);
// out objects
Rcpp::NumericVector Vout(A.length());
Rcpp::NumericVector Dout(A.length());
// read dimension attribute of IN arrays
Rcpp::IntegerVector d1 = A.attr("dim");
Rcpp::IntegerVector d2 = A2.attr("dim");

// create 2 blitz cubes B1 and B2
// Note that by default, Blitz arrays are row-major. 
// From R and Fortran, we get column major arrays. so use option "fortranArray" to define storage order.
blitz::Array<double,3> B1(A.begin(), shape(d1(0),d1(1),d1(2)), neverDeleteData, fortranArray);
blitz::Array<double,3> B2(A2.begin(), shape(d2(0),d2(1),d2(2)), neverDeleteData, fortranArray);

// declare blitz dimension descriptors
firstIndex  i;
secondIndex  j;
thirdIndex  k;

// create to "value functions" to store values after maximizing
// over the third dimension of B1 and B2
blitz::Array<double,2> V1(d1(0),d1(1),fortranArray);
blitz::Array<double,2> V2(d1(0),d1(1),fortranArray);

// maximize over third dim
V1 = max(B1,k);
V2 = max(B2,k);

// map as blitz arrays
blitz::Array<double,2> Vmax(Vout.begin(), shape(d1(0),d1(1)), neverDeleteData,fortranArray);
blitz::Array<double,2> Dmax(Dout.begin(), shape(d2(0),d2(1)), neverDeleteData,fortranArray);

// take discrete choice
Vmax = where(V1 > V2, V1, V2);
Dmax = where(V1 > V1, 1, 2);

// copy to NumericVectors
Vout = Vmax;
Dout = Dmax;

// add dimension attributes
// http://gallery.rcpp.org/articles/accessing-xts-api/
Vout.attr("dim") = Rcpp::IntegerVector::create(d1(0),d1(1));
Dout.attr("dim") = Rcpp::IntegerVector::create(d1(0),d1(1));
Rcpp::List list = Rcpp::List::create( _["vmax"] = Vout, _["dchoice"] = Dout);
return list;


'

A = array(1:60,c(2,5,6))
A2 = array(120:60,c(2,5,6))
V = array(0,c(2,5))

f2 = cxxfunction(signature(A_="numeric",A2_="numeric"),body=src,plugin="Rcpp",includes=inc)
result = f2(A,A2)

# R result
r = list()
V1 = apply(A,c(1,2),max)
V2 = apply(A2,c(1,2),max)
V12 = array(c(V1,V2),c(2,5,2))
r$vmax = apply(V12,c(1,2),max)
r$dchoice = apply(V12,c(1,2),which.max)

all.equal(result,r)
