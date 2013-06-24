This section will described how to use the `data.table` package. This package is a much faster implementation of the `data.frame` object which it also extends.

## The structure of data.table

A data.table is a collection of vectors of identical length. Each vector forms a column, and so the data.frame can be thought of as a table with a number of row and a number of columns. Those structures are often called `rogue arrays` (an non rogue array has a same type in every column).

So we can easily create such an object:


```r
require(data.table)
```

```
## Loading required package: data.table
```

```r
v1 = seq(0, 1, l = 10)
v2 = sample(c("a", "b", "c"), 10, replace = TRUE)
dd = data.table(i = v1, l = v2)
dd
```

```
##          i l
##  1: 0.0000 c
##  2: 0.1111 c
##  3: 0.2222 a
##  4: 0.3333 c
##  5: 0.4444 b
##  6: 0.5556 c
##  7: 0.6667 b
##  8: 0.7778 b
##  9: 0.8889 b
## 10: 1.0000 b
```


Then columns can be accessed by names using the dollar sign.


```r
dd$i
```

```
##  [1] 0.0000 0.1111 0.2222 0.3333 0.4444 0.5556 0.6667 0.7778 0.8889 1.0000
```


## The 3 arguments of `[` in data.table

the first argument allows to subset the data, the second allows to perform function on that subset, the third argument allows to apply the function by groups. TBD.


## Using `keys`

Here we show how the keys optins can be used to compute lag variables in a `data.table`. This requires that you understood the way data.table works. 

For this we are going to use a simulated dynamic panel. This panel will represent draws from an AR(1) process with a random effect

$$latex
  y_{it} = \rho * y_{it-1} + f_{i} + u_{it} 
$$

Let's first generate the data in a very crude and slow way.

```r
p = list(n = 20, t = 10, rho = 0.8, f_sd = 0.2, y0_sd = 1, u_sd = 1)

# create 1 entry per individual and draw a random length
dd = data.table(i = 1:p$n, l = rpois(p$n, p$t), y0 = rnorm(p$n, sd = p$y0_sd), 
    f = exp(rnorm(p$n, sd = p$y0_sd)))

# for each individual we create the time series
dd = dd[, {
    y = rep(0, l)
    y[1] = y0
    u = rnorm(l, sd = p$u_sd)
    for (t in 2:l) {
        y[t] = p$rho * y[t - 1] + f
    }
    list(y = y, t = 1:l)
}, i]
```


we plot for a few indidividuals:

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 


