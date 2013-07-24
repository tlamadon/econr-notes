Solving a simple 2-period Consumption problem with RcppGSL
========================================================

In this example we demonstrate how to solve the following problem using the RcppGSL package. GSL is the [[GNU scientific library]](https://www.gnu.org/software/gsl/) and has many useful functions written in C++. RcppGSL is the Rcpp interface for R. Please look at the separate chapter "how to install RcppGSL" as that needs a trick or two.

## problem

$$ \begin{array}{ccc} max_x &\log(a - x) + \beta log(x) \\
                           &x \in [0.1,11],\\
                           &a \in {2,3,\dots,10}
                     \end{array}$$

This is the simplest problem one could try to solve. to add at least some realism, we will linearly interpolate the "future value" $ log(x) $, as our problems most of the times do not admit a closed form of this object.

### Solution

The good thing is that there is an analytic solution to this. Taking the derivative w.r.t. x one obtains

$$ \begin{array}{cccc} \frac{1}{a-x}        &=& \beta \frac{1}{x} \\
                     \beta (a-x)           &=& x \\
                     \beta a               &=& x (1+\beta) \\
                     a\frac{\beta}{1+\beta} &=& x 
                     \end{array} $$
                     
which implies that savings $x$ are a constant fraction of current assets.


```r
library(RcppGSL)
```

```
## Loading required package: Rcpp
```

```
## Warning: package 'Rcpp' was built under R version 2.15.3
```

```r
library(inline)
```

```
## Attaching package: 'inline'
```

```
## The following object(s) are masked from 'package:Rcpp':
## 
## registerPlugin
```

```r

# there is some weird thing going on with assets here.  it seems the
# C-function modifies the values of the assets object in R now idea why
# that happens. create a second object assets2 just to be sure.

# define asset and savings grid
assets <- seq(2, 10, le = 9)
assets2 <- seq(2, 10, le = 9)
saving <- seq(0.1, 11, le = 50)

Beta <- 0.95
verbose <- FALSE  # set FALSE to supress printing the trace of the optimizer
```


### Rcpp Inline

We will use the inline package to write C source code inline. Then we compile the source in place to a C function, and we call it from R. See chapter "intro to Rcpp".

First, define a string "inc" to be our personal header file for the C function:


```r
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

  // if consumption negative, very large value
	if (res<0) {
		out =  1e9;
	} else {
		out = - (log(res) + beta*ev);
	}
	return out;
}
'
```



### testing the objective function

here's a code snippet that will print the value of the ojbective at different asset and savings states:


```r
src <- '
NumericVector a(a_);
NumericVector aa(aa_);
double beta  = as<double>(beta_);
NumericVector ay = log(aa);  // future values

int m = aa.length();
int n = a.length();

NumericMatrix R(n,m);

gsl_interp_accel *accP = gsl_interp_accel_alloc() ;
gsl_interp *linP = gsl_interp_alloc( gsl_interp_linear , m );
gsl_interp_init( linP, aa.begin(), ay.begin(), m );

gsl_function F;

F.function = &my_obj;

for (int i=0;i < a.length(); i++){
  // define the struct on that state
	struct my_f_params params = {a(i),beta,linP,accP,aa,ay};
	F.params   = &params;
	//Rcout << "asset state :" << i << std::endl;
	//Rcout << "asset value :" << a(i) << std::endl;
	for (int j=0; j < m; j++) {
		//Rcout << "saving value :" << aa(j) << std::endl;
		//Rcout << GSL_FN_EVAL(&F,aa(j)) << std::endl;
    R(i,j) = GSL_FN_EVAL(&F,aa(j));
	}
    
}
return wrap(R);
'

# here we compile the c function:
testf=cxxfunction(signature(a_="numeric",aa_="numeric",beta_="numeric"),body=src,plugin="RcppGSL",includes=inc)

# here we call it
res1 <- testf(a_=assets,aa_=saving,beta_=Beta)
tmp = res1  
tmp[tmp==1e9] = NA  # the value 1e9 stands for "not feasible"
persp(tmp,theta=100,main="objective function",ticktype="detailed",x=assets,y=saving,zlab="objective function value")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.png) 


### Setup the optimizer 

this is a bit messy. needs much more commenting:


```r
src2 <- '
// map values from R
NumericVector a(a_);
NumericVector aa(aa_);
double beta = as<double>(beta_);
bool verbose = as<bool>(verbose_);
NumericVector ay = log(aa);  // future values
NumericVector R(a_);

// optimizer setup
int status;
int iter=0,max_iter=100;
const gsl_min_fminimizer_type *T;
gsl_min_fminimizer *s;

int k = aa.length();

gsl_interp_accel *accP = gsl_interp_accel_alloc() ;
gsl_interp *linP       = gsl_interp_alloc( gsl_interp_linear , k );
gsl_interp_init( linP, aa.begin(), ay.begin(), k );

// parameter struct
struct my_f_params params = {a(0),beta,linP,accP,aa,ay};

// gsl objective function
gsl_function F;
F.function = &my_obj;
F.params   = &params;

// bounds on choice variable
double low = aa(0), up=aa(k-1);
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

	struct my_f_params params = {a(i),beta,linP,accP,aa,ay};
	F.params   = &params;

	// if optimization bounds change do that here

	low = aa(0); 
	up=aa(k-1);
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
```


#### compiling the C function


```r
f2=cxxfunction(signature(a_="numeric",aa_="numeric",beta_="numeric",verbose_="logical"),body=src2,plugin="RcppGSL",includes=inc)

# setup a wrapper to call. optional
myfun <- function(ass,sav,Beta,verbose){
  res <- f2(ass,sav,Beta,verbose)
	return(res)
}

myres <- myfun(assets,saving,Beta,verbose)
```


#### look at result

we can compare the analytical solution to the one we found by just plotting the optimal savings choices:


```r
plot(assets2, assets2 * Beta/(1 + Beta), col = "red")
lines(assets2, myres)
legend("bottomright", legend = c("true", "approx"), lty = c(1, 1), 
    col = c("red", "black"))
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 


##### How far is our solution from the closed form?


```r
print(max(assets2 * Beta/(1 + Beta) - myres))
```

```
## [1] 0.05496
```

