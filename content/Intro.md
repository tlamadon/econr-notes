## Introduction {#Home}

On this website we collect notes on how to use `R/C++` programming to solve quantitative economic models with heterogeneous agents.
The ultimate aim is to produce a book with all the content we gather - we encourage contributions from others!

We think the content presented here could be useful for economics grad students and researchers who want to solve computationally
intensive economics models. We don't target any particular subfield of economics (like *finance*, or *macro*), but we show by
way of fully worked examples how one can combine `R` and `C++` or `fortran` to compute large scale problems. 

Many economists seem to think that *computationally intensive* is another way of saying *use fortran*. Whilst our agenda is not to prove
anyone wrong here, we do want to illustrate that there are serious alternatives to using plain fortran. We will try to flesh out the
pros and cons of each approach.

The main motivation for this book lies in the fact that we think there is a shortage of books that help implementing solutions for computational economics. Beware that this book
is **not** a substitute to any of the excellent existing contributions on computational economics, like [Ken Judd's book](http://www.amazon.com/Numerical-Methods-Economics-Kenneth-Judd/dp/0262100711),
[Adda and Cooper](http://mitpress.mit.edu/books/dynamic-economics) or [Fackler and Miranda](http://www.amazon.co.uk/Applied-Computational-Economics-Finance-Miranda/dp/0262633094), to name but a few. However, we feel that there is space for a more hands on approach,
with actual working computer code instead of pseudo code illustrations. Economics students and researchers spend a lot of time
*making things work*, many times on problems that others have solved before. We want to make a small contribution to alleviate
this inefficiency.

A similar but extremely accomplished book is [Quantitative Economics](http://quant-econ.net/index.html) by  John Stachurski and Thomas J. Sargent. Their book uses the `python` language which we also really like. We hope that the notes we present here can complement the content of their book with applications focused on the use of `R/C++`.

Finally, we would like to refer to several other `R`-related publications which may be useful:

- [Rcpp by Dirk Eddelbuettel](http://www.amazon.co.uk/Seamless-Integration-Rcpp-Dirk-Eddelbuettel/dp/1461468671): We heavily use the [Rcpp package](http://cran.r-project.org/web/packages/Rcpp/index.html) for seamless integration of R and C++. Although we provide a cursory overview of Rcpp, there is no real substitute to Dirk's book for a more thorough description. Also check out the vast amount of slides and training material [on his website](http://dirk.eddelbuettel.com/).
- [ggplot2 by Hadley Wickham](http://www.amazon.co.uk/ggplot2-Elegant-Graphics-Data-Analysis/dp/0387981403): ggplot2 is an excellent graphics package for `R`. For many, ggplot2 is reason enough to use `R`. 
- [R/C++ programing by Hadley Wickham](http://adv-r.had.co.nz/): a non econ-centric introduction to `R` and `C++`. Tons of material on R development.
- [Applied Econometrics with R by Kleiber and Zeileis](http://www.amazon.co.uk/Applied-Econometrics-R-Use/dp/0387773169): an excellent little book on how to do state of the art applied econometrics with R. (It is not true that you need stata to run a probit.)

Thanks for stopping by, Thibaut & Florian.

(Please do leave comments at the bottom of each page!)
