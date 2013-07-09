When writing compiled code for R, one might want to use the intel compiler (icc or ifort) since they can deliver some
really significatn improvments ( sometimes factor 10) over the gnu compiler.

For this reason here we'll brieflfy described how to build `R3` with the intel compiler and configure it to use those compiler when using Rcpp or using the inline functions.


## step 1, get intel compilers

If you already have the intel compiler installed, then you should skip this section. If you don't you need to get the `C` toolbox and the `fortran` toolbox. For non-commercial use, on a linux machine you can get it from here:

[Non commercial intel suites](http://software.intel.com/en-us/non-commercial-software-development)

Sign up, get your licence key, download the massive libraries.

Then untar the libraries and install then using `./install.sh`. It should be extremely straight forward.

## step 2 configure R

modify the `config.site` and add:

    CC=icc
    #CC="icc -std=c99"
    CFLAGS="-g -O3 -wd188 -ip -mp"
    F77=ifort
    FLAGS="-g -O3 -mp"
    CXX=icpc
    CXXFLAGS="-g -O3 -mp"
    FC=ifort
    FCFLAGS="-g -O3 -mp"
    ICC_LIBS=/opt/intel/composerxe-2011.3.174/compiler/lib/intel64
    IFC_LIBS=/opt/intel/composerxe-2011.3.174/compiler/lib/intel64
    LDFLAGS="-L$ICC_LIBS -L$IFC_LIBS -L/usr/lib64"
    SHLIB_CXXLD=icpc
    # CPPFLAGS=-no-gcc
    SHLIB_LDFLAGS="-shared"
    SHLIB_CXXLDFLAGS="-shared"

then run 

    ./configure --enable-R-shlib --enable-threads=posix --with-lapack --with-blas="-fopenmp -m64 -I$MKLROOT/include -L$MKLROOT/lib/intel64 -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lpthread -lm"
    make
    make install

and you are done! Now things will be compiled using `icc`, `icpc` and `ifort`, plus R will use the `MKL` library. I will add some benchmarks soon. 