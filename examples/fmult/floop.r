dyn.load('fmult.so')

A = array(runif(100),c(10,10))
X = array(runif(10),c(10))

cat('calling fortran\n')
res = .Fortran('fmult', A=A, X=X, Y=double(length(X)),as.integer(dim(A)[1]),as.integer(dim(A)[2]))
cat('done\n')

print(res)  

