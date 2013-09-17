A quick reminded on setting up and using root finding and minimization in RcppRgsl.

## 1D root finding

```cpp
double find_root(gsl_root_fsolver *s, gsl_function * F, double a, double b, double w) {
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
  } while (status == GSL_CONTINUE && iter < max_iter);

  return( (1.0-w) * x_lo +   w * x_hi );
}

```



```cpp

// init
const gsl_root_fsolver_type *T2 = gsl_root_fsolver_brent;
gsl_root_fsolver *rootfinder   = gsl_root_fsolver_alloc (T2);

// use the defined function
xstart = find_min(rootfinder, ....)

// clean
gsl_min_fminimizer_free   (minimizer);
gsl_root_fsolver_free(rootfinder);

```

