
# same as max3.r but solving the first order condition instead of the objective function


rm(list=ls())

library(RcppGSL)
library(inline)


a  <- seq(2,10,le=9)
x  <- seq(0.1,11,le=50)

Beta <- 0.95
verbose <- FALSE # set FALSE to supress printing the trace of the optimizer

cat('this example has a closed form solution. the setup is\n
	max log(a - x) + beta * log(x) \n
	and the optimal choice x satisfies \n
	a * beta/(1+beta) = x\n
	we attempt to solve for a zero in the first order condition\n')


inc <- '
#include <gsl/gsl_roots.h>

// this struct will hold parameters we need in the objective
struct my_f_params { double a; double beta; };

double my_obj( double x, void *p){
  struct my_f_params *params = (struct my_f_params *)p;
	double a                   = (params->a);
	double beta                = (params->beta);
        
	double res;

	res = x - beta*(a - x);
	return res;
}

double find_root(gsl_root_fsolver *s, gsl_function * F, double a, double b) {
  int iter = 0, max_iter = 100 ,status;
  double r, x_lo,x_hi;

  gsl_root_fsolver_set (s, F, a, b);
  do {
    iter++;
    status = gsl_root_fsolver_iterate (s);
    r      = gsl_root_fsolver_root (s);
    x_lo   = gsl_root_fsolver_x_lower (s);
    x_hi   = gsl_root_fsolver_x_upper (s);
    status = gsl_root_test_interval (x_lo, x_hi,
                                     0, 0.001);
    // if (status == GSL_SUCCESS)
    //   printf ("Converged:\\n");
    //
    // printf ("%5d [%.7f, %.7f] %.7f %+.7f %.7f\\n",
    //         iter, x_lo, x_hi,
    //         r, r - r_expected, 
    //         x_hi - x_lo);
  } while (status == GSL_CONTINUE && iter < max_iter);

  return( (x_lo + x_hi)/2.0);
}
'

# test obj function
# print function values at different states and savings choices

src <- '
NumericVector a(a_);	// a has the same memory address as a_
NumericVector x(x_);
double beta  = as<double>(beta_);

int m = x.length();
int n = a.length();

// R is the matrix of return values
NumericMatrix R(n,m);

// param struct
struct my_f_params params = {a(0),beta};

// gsl objective function
gsl_function F;

//point to our objective function
F.function = &my_obj;
F.params   = &params;

// --------------------------------
// loop over rows of R: values of a
// --------------------------------

for (int i=0;i < a.length(); i++){

  // define the struct on that state:
  // notice that the value of the state a(i) changes
	params.a = a(i);

  // uncomment those lines to print intermediate values
	//Rcout << "asset state :" << i << std::endl;
	//Rcout << "asset value :" << a(i) << std::endl;

  // --------------------------------
  // loop over cols of R: values of x
  // --------------------------------

	for (int j=0; j < m; j++) {
		//Rcout << "saving value :" << x(j) << std::endl;
		//Rcout << GSL_FN_EVAL(&F,x(j)) << std::endl;
    R(i,j) = GSL_FN_EVAL(&F,x(j));
	}
    
}
return wrap(R);
'


# uncomment to print test values from objective
testf=cxxfunction(signature(a_="numeric",x_="numeric",beta_="numeric"),body=src,plugin="RcppGSL",includes=inc)

# here we call it
 res1 <- testf(a_=a,x_=x,beta_=Beta)

# res1[res1==1e9] = NA  # the value 1e9 stands for "not feasible"
# persp(res1,theta=100,main="objective function",ticktype="detailed",x=a,y=x,zlab="objective function value")

library(rgl)
open3d()
surface3d(a,x,res1*0.3,color="red",alpha=0.8)  # scaled res1
axes3d(labels=FALSE,tick=FALSE)
planes3d(a=0,b=0,c=-1,d=0,color="blue",alpha=0.8)
title3d("first order condition has a zero everywhere")



cat('testing optimizer now\n')

# test optimizer
src2 <- '
// map values from R
NumericVector a(a_);
NumericVector x(x_);
double beta = as<double>(beta_);
bool verbose = as<bool>(verbose_);
NumericVector ay = log(x);  // future values

int na = a.length();

NumericVector R(na);   // allocate a return vector

// optimizer setup
int status;
int iter=0,max_iter=100;

int k = x.length();

// initialize the root finder
const gsl_root_fsolver_type *T2 = gsl_root_fsolver_brent;
gsl_root_fsolver *rootfinder    = gsl_root_fsolver_alloc (T2);

// parameter struct
struct my_f_params params = {a(0),beta};

// gsl objective function
gsl_function F;
F.function = &my_obj;
F.params   = &params;

// bounds on choice variable
double low = x(0), up=x(k-1);
double root;

// loop over states
for (int i=0;i < a.length(); i++){

	params.a = a(i);

	root = find_root( rootfinder, &F, low, up);
	
	R(i) = root;
}
gsl_root_fsolver_free( rootfinder );
return wrap(R);
'
f2=cxxfunction(signature(a_="numeric",x_="numeric",beta_="numeric",verbose_="logical"),body=src2,plugin="RcppGSL",includes=inc)

# setup a wrapper to call. optional
myfun <- function(ass,sav,Beta,verbose){
  res <- f2(ass,sav,Beta,verbose)
	return(res)
}

myres <- myfun(a,x,Beta,verbose)

#### look at result


plot(a,a*Beta/(1+Beta),col="red")
lines(a,myres)
legend("bottomright",legend=c("true","approx"),lty=c(1,1),col=c("red","black"))

##### How far is our solution from the closed form?

print(max(a * Beta/(1+Beta) -myres))
