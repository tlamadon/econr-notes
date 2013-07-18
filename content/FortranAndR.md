
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
suroutine mutlmat(A,X,Y)
external Y
real, dimension(:,:), allocatable  :: A
real, dimension(:),   allocatable  :: X

DO (i = lbound (A,1), ubound (A,1))
DO (j = lbound (A,2), ubound (A,2))
  Y[i] = Y[i] + A[i,j]*X[j] 
end do
end do
```

save this code to `fmult.f90` , we then compile it into a library using the following command:

    R CMD SHLIB fmult.f90





## links

[howto on returning an array](http://math.acadiau.ca/ACMMaC/howtos/Fortran_R.html)
[f90 array sizes](http://www.nsc.liu.se/~boein/f77to90/a3.html#section10)