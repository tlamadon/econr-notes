It can be very difficult to debug compiled code when linked within R. The goal of this section is to show how this process can be made easier with the use of some of the c++ tool chain. We'll cover the following:

 - use `assert` to check catch issues in non production phase
 - use `gdb` to find where a crash happens

## A simple crashing routine

Let's write a simple RcppGSL function that performs a spline interpolation. The error will happen because we are going to ask for an evaluation that is outside the support.

```cpp
#include<iostream>
using namespace std;

RcppExport SEXP cpp_lagrWithEffort( SEXP R_args){
  BEGIN_RCPP

  bool crashit = Rcpp::as<bool>(R_args);

  if (crashit) {
	  int x = 7;
	  int *p = 0;

	  cout << "x = " << x;
	  cout << "The pointer points to the value " << *p;
  } else {
      cout << "you are lucky." << endl;
  }
  return(NULL);
  
  END_RCPP
}

```

## Using assert

I recommend using the following simple macro. Copy the code snippet into an `assert.h` file that you can then include in yrou code.

```cpp
#ifndef DEBUG
#define ASSERT(x)
#else
#define ASSERT(x) \
 if (! (x)) \
 { \
    cout << "ERROR!! Assert " << #x << " failed\n"; \
    cout << " on line " << __LINE__  << "\n"; \
    cout << " in file " << __FILE__ << "\n";  \
 }
#endif
```

Then you can populate your code with various assertion commands.

## Using gdb

Start R in debug mode using 

```sh
R -d gdb -e "source('tmp.r')"
```

you will then get a prompt. Declare some breakpoints, for example here I catcth the call to `exit`:

```sh
break exit
```

when the program crashes, I can display the stack by calling `backtrace`. It is important to remember compiling the code with the flags `-rdynamic -g` to get correct information. Later on for speed the code should be recompiled without the `-g` file and probably using the `-O3` flag.


## an example debugging session

tbd
