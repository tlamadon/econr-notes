A quick note on generating random numbers in C++. I will just present how to use the gsl random number generator. See full details on the [GSL help page](http://www.gnu.org/software/gsl/manual/html_node/Random-Number-Distributions.html#Random-Number-Distributions).

First one need to do the overall initialization by doing:

<pre><code class="cpp">const gsl_rng_type * rT;
gsl_rng * rgen;
rT   = gsl_rng_default;
rgen = gsl_rng_alloc (rT);
</code></pre>

Then here is how to use each particular random number generator:


<table class="table table-hover">

<tr><th>discrete</th><td><pre><code class="cpp">gsl_ran_discrete_t * F;
F = gsl_ran_discrete_preproc(nx, Unif);
...
draw = gsl_ran_discrete(rgen, F);
...
gsl_ran_discrete_free(F);
</code></pre></td></tr>


<tr><th>binomial</th><td>
<pre><code class="cpp">// no init
...
draw = gsl_ran_binomial(rgen,pr,1);
...
// no deallocate
</code></pre></td></tr>


<tr><th>uniform</th><td><pre><code class="cpp">// no init
...
draw = gsl_rng_uniform(rgen);
...
// no deallocate
</code></pre></td></tr>


<tr><th>uniform discrete</th><td><pre><code class="cpp">// no init
...
draw = gsl_rng_uniform_int(rgen,n);
...
// no deallocate
</code></pre></td></tr>



</table>

