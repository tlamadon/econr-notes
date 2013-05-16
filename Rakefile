

BOOK_CONTENT = [
  "Introduction",
  "Chapter1"
]


# define a function that extracts the TOC
# just pasrse the files and collect whatever
# starts with # (any number of them) and collect 
# the links.




task :default do

  #for chapter in BOOK_CONTENT
  #  puts "This is a chapter #{chapter}"
  #end
  system "cp content/Intro.md build"

  system "cd build; Rscript -e \"options(encoding='UTF-8'); require(knitr); knit('../content/chapter1.Rmd');\""
  system "cd build; pandoc --mathjax -s chapter1.md  -t html -o book1.html"
  system "cd build; pandoc --mathjax -s chapter1.md  -t html -o book1.html"


  #system "cd build; Rscript -e \"options(encoding='UTF-8'); require(knitr); knit('../content/chapter2.Rrst');\""
  #system "cd build; pandoc --mathjax -s chapter2.rst -t html -o book2.html"
end

task :pdf do
  system "cd build; pandoc --chapters --toc -s *.md -t latex -o book.pdf"
end

task :html do
# good options
# --id-prefix=   to add a prefix to all links in a file

  system "cd build; pandoc --mathjax -s Intro.md -t html -o Intro.html"
  system "cd build; pandoc --mathjax -s chapter1.md -t html -o chapter1.html"
end


