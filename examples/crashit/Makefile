export PKG_CPPFLAGS=`Rscript -e 'Rcpp:::CxxFlags()'` 
export PKG_LIBS=`Rscript -e 'Rcpp:::LdFlags()'`

all: 
	R CMD SHLIB crashit.cpp
	
clean:
	rm -rf *.o *.so
	
