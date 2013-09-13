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
	a * beta/(1+beta) = x')


inc <- '
#include <gsl/gsl_min.h>
#include <gsl/gsl_interp.h>

// this struct will hold parameters we need in the objective
// those contain also the approximation object "myint" and 
// corresponding accelerator acc
struct my_f_params { double a; double beta; const gsl_interp *myint; gsl_interp_accel *acc; NumericVector xx;NumericVector y;};

// note that we want to MAXIMIZE value, but the algorithm
// minimizes a function. we multiply return values with -1 to fix that.

double my_obj( double x, void *p){
  struct my_f_params *params = (struct my_f_params *)p;
	double a                   = (params->a);
	double beta                = (params->beta);
	const gsl_interp *myint    = (params->myint);
	gsl_interp_accel *acc      = (params->acc);
	NumericVector xx           = (params->xx);
	NumericVector y            = (params->y);
        
	double res, out, ev;

	// obtain interpolated value

	ev = gsl_interp_eval(myint, xx.begin(), y.begin(), x,acc);

	res = a - x;	//current resources

  // if consumption negative, very large penalty value
	if (res<0) {
		out =  1e9;
	} else {
		out = - (log(res) + beta*ev);
	}
	return out;
}
'

# test obj function
# print function values at different states and savings choices

src <- '
NumericVector a(a_);	// a has the same memory address as a_
NumericVector x(x_);
double beta  = as<double>(beta_);
NumericVector ay = log(x);  // future values

int m = x.length();
int n = a.length();

// R is the matrix of return values
NumericMatrix R(n,m);

//initiate gsl interpolation object
gsl_interp_accel *accP = gsl_interp_accel_alloc() ;
gsl_interp *linP = gsl_interp_alloc( gsl_interp_linear , m );
gsl_interp_init( linP, x.begin(), ay.begin(), m );

gsl_function F;

//point to our objective function
F.function = &my_obj;

// --------------------------------
// loop over rows of R: values of a
// --------------------------------

for (int i=0;i < a.length(); i++){

  // define the struct on that state:
  // notice that the value of the state a(i) changes
	struct my_f_params params = {a(i),beta,linP,accP,x,ay};
	F.params   = &params;

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
# testf=cxxfunction(signature(a_="numeric",x_="numeric",beta_="numeric"),body=src,plugin="RcppGSL",includes=inc)

# here we call it
# res1 <- testf(a_=a,x_=x,beta_=Beta)
# res1[res1==1e9] = NA  # the value 1e9 stands for "not feasible"
# persp(res1,theta=100,main="objective function",ticktype="detailed",x=a,y=x,zlab="objective function value")

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
const gsl_min_fminimizer_type *T;
gsl_min_fminimizer *s;

int k = x.length();

gsl_interp_accel *accP = gsl_interp_accel_alloc() ;
gsl_interp *linP       = gsl_interp_alloc( gsl_interp_linear , k );
gsl_interp_init( linP, x.begin(), ay.begin(), k );

// parameter struct
struct my_f_params params = {a(0),beta,linP,accP,x,ay};

// gsl objective function
gsl_function F;
F.function = &my_obj;
F.params   = &params;

// bounds on choice variable
double low = x(0), up=x(k-1);
double m = 0.2;	//current minium

// create an fminimizer object of type "brent"
T = gsl_min_fminimizer_brent;
s = gsl_min_fminimizer_alloc(T);

printf("using %s method\\n", 
	   gsl_min_fminimizer_name(s));

for (int i=0;i < a.length(); i++){

	// load current grid values into struct
	// if interpolation schemes depend on current state
	// i, need to allocate linP(i) here and then load into
	// params

	struct my_f_params params = {a(i),beta,linP,accP,x,ay};
	F.params   = &params;

	// if optimization bounds change do that here

	low = x(0); 
	up=x(k-1);
	iter=0;	// reset iterator for each state
    m = 0.2; // reset minimum for each state

	// set minimzer on current obj function
	gsl_min_fminimizer_set( s, &F, m, low, up );

    // print results
	if (verbose){
	printf (" iter lower      upper      minimum      int.length\\n");
			printf ("%5d [%.7f, %.7f] %.7f %.7f\\n",
			iter, low, up,m, up - low);
	}
    
    // optimization loop
    do {
		iter++;
		status = gsl_min_fminimizer_iterate(s);
		m      = gsl_min_fminimizer_x_minimum(s);
		low    = gsl_min_fminimizer_x_lower(s);
		up     = gsl_min_fminimizer_x_upper(s);

		status = gsl_min_test_interval(low,up,0.001,0.0);

		if (status == GSL_SUCCESS && verbose){
		    Rprintf("Converged:\\n");
		}
		if (verbose){
		printf ("%5d [%.7f, %.7f] %.7f %.7f\\n",
				iter, low, up,m, up - low);
		}
	} 
	while (status == GSL_CONTINUE && iter < max_iter);
	R(i) = m;
}
gsl_min_fminimizer_free(s);
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
