
#include <iostream>
#include <Rcpp.h>

using namespace std;

RcppExport SEXP crashit( SEXP R_args){
  BEGIN_RCPP

  bool crashit = Rcpp::as<bool>(R_args);

  if (crashit) {

	  int x = 7;
	  int *p = 0;

	  cout << "x = " << x;
	  cout << "The pointer points to the value " << *p;

  } else {

      cout << "you are lucky." << endl;

  }
  return 0 ;
  
  END_RCPP
}
