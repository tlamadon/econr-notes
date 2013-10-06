Projects that containts the sources to the book [Introduction to heterogenous agent economics with R/C++](http://www.econr.org). 

## generate the content

    rake html
    rake pdf

## Adding content

### folder structure

The folder structure is as follows:

 - content:   this is the book content written in R/Markdown
 - templates: different formatting files to produce latex and html outputs
 - lib:       static content this library depends on like bootstrap.
 - build:     used to generate the content


### Writing chapters as several files

Use one sharp sign for chapter titles and then add more for sections / subsections. Chapter can one file or they can split among several files. The depth of a given file will be inferred from the number of sharp signs on the firt line of the file.

This will allow us to split documents hwoever we want at writing and at rendering.

## Using

 - mustache
 - rake
 - pandoc
 - mathjax
 - bootstrap
