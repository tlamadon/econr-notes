
# Rcpp + Inline primer

In this section we give a quick overview of how to use Rcpp together with the inline package
to do fast C++ prototyping in R.

Throughout this book you will encounter snippets of code which contain a string,
which represents C++ source code, as here:

```r
src <- '
    NumericVector one = as<NumericVector>(A);
    double two        = as<double>(b);
    // do something here ...
    '
```

in this instance we create an R string `src` that represents C++ code. We created 
a `NumericVector` called *one* and `double` called *two*, by using the Rcpp function
`as()` that allows us to map `R` objects to `C++`.

In the next step we would compile our source code `src` by using the `inline` package 
function `cxxfuntion()`:

```r
myfun <- cxxfunction(signature(A="numeric",b="numeric"),body=src,plugin="Rcpp")
```

