

# How to install Rmpi on a Scientific Unix Cluster


## load the right modules

1. module add openmpi/gcc
2. module add r

This loads the most recent version of R, which is probably what you want. If you want a specific version x.y, load r/x.y.

## install Rmpi

this is very easy. start R on the hpc console (type `R`). then do

```r
install.packages("Rmpi",configure.args=c("--with-Rmpi-include=/cm/shared/apps/openmpi/gcc/64/1.4.5/include",
                                         "--with-Rmpi-libpath=/cm/shared/apps/openmpi/gcc/64/1.4.5/lib64",
                                         "--with-Rmpi-type=OPENMPI"))
```

you will be asked if you want to install to a personal library. say yes.

## install snow

```r
install.packages('snow')
```

## run a test

### if you have git

clone the git test repository with `git clone git@github.com:floswald/mpitest.git` on the hpc. 

### alternatively download the repository

to a folder on the hpc. 

1. go to `mpitest/R/singleThread/flos-test/` and 
2. type `make` and hit enter. 
3. if everything was installed correctly a test will use 3 nodes and do some things. 
4. check the file `exp.Rout` for correct output.
