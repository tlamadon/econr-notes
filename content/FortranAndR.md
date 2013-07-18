
Eventhough I highly recommend using `C++` together with `R`, in some cases fortran can be faster. For simple problems that do not require additional libraries and when the `intel` compiler is avaibalbe, `f90` can be a very good option.

In this note we will see how one can write some `f90` code and call it from `R`. You will notice however how this procedure is less convenient than when using `Rcpp`.


## Overview of the process

What needs to be done is:

 - write a Fortran subroutine
 - compile the subroutine
 - load the generated library in R
 - call the function in R

## the f90 subroutine

let's write a very simple matrix multiplication 

```f90
subroutine fmult(A,X,Y,n,m)
implicit none

integer :: n,i,j
double precision,dimension(n,m) :: A
double precision,dimension(m) :: X
double precision,dimension(n) :: Y

do i = 1,n
Y(i)=0
do j = 1,m
  Y(i) = Y(i) + A(i,j,1) * X(j) 
end do
end do

end
```

save this code to `fmult.f90` , we then compile it into a library using the following command:

    R CMD SHLIB fmult.f90

at this point we can start R, load the library and call the function:

```R
dyn.load('fmult.so')

A = array(runif(100),c(10,10))
X = array(runif(10),c(10))
res = .Fortran('fmult', A=A, X=X, Y=double(length(X)),as.integer(dim(A)[1]),as.integer(dim(A)[2]))
print(res$Y)
```  

## R wrapper function

Now we want to write a wrapper that will call the `f90` function. `Rcpp` and `inline` are packages that do this automatically. Unfortunately, at the moment, neither seems to work properly with `f90` so we will do it by hand.

```R
matmult <- function(A,X) {

  if (!is.loaded(symbol.For('fmult'))) {
      dyn.load('fmult.so')
  }  
  res = .Fortran('fmult', A=A, X=X, Y=double(length(X)),as.integer(dim(A)[1]),as.integer(dim(A)[2]))
  return(res$Y)
}
```
and we are done!

## links

 - [howto on returning an array](http://math.acadiau.ca/ACMMaC/howtos/Fortran_R.html)
 - [f90 array sizes](http://www.nsc.liu.se/~boein/f77to90/a3.html#section10)