

BOOK_CONTENT = [
  "Intro",
  "chapter1",
  "DataTable",
  "savingRcppGSL",
  "FortranAndR"
]

# define a function that extracts the TOC
# just pasrse the files and collect whatever
# starts with # (any number of them) and collect 
# the links.
require 'rake/clean'
require 'mustache'

OBJDIR = 'build'
SRCDIR = 'content'

RMD_FILES      = FileList['content/*.Rmd']
MARKDOWN_FILES = BOOK_CONTENT.collect { |fs| File.join(OBJDIR, File.basename(fs).ext('md')) }
HTML_FILES     = BOOK_CONTENT.collect { |fs| File.join(OBJDIR, File.basename(fs).ext('html')) }

# CLEAN.include(MARKDOWN_FILES)
# CLEAN.include(HTML_FILES)
# CLEAN.include("build/book.pdf")
CLEAN.include(OBJDIR)

# task that processes all Rmd files
task :makeMarkdownFiles     => MARKDOWN_FILES
task :makeHtmlFiles         => HTML_FILES

# making sure build folder exists
directory OBJDIR

# rule to build Rmd files
rule '.md' => [ proc { |tn| File.join(SRCDIR, File.basename(tn).ext('Rmd')) },'%d'] do |t|
    system "cd build; Rscript -e \"options(encoding='UTF-8'); require(knitr); knit('../#{t.source}');\""
end

# rule to copy markdown files
rule /build.*.md/ => [ proc { |tn| File.join(SRCDIR, File.basename(tn).ext('md')) },'%d'] do |t|
    system "cp #{t.source} #{t.name}"
end

# rule to copy markdown files
rule '.html' => '.md' do |t|
  #system "pandoc --mathjax -s #{t.source} -t html -o #{t.name}"
  system "pandoc --mathjax -s #{t.source}" +
         " -t html -o #{t.name} " +
         " --template ~/git/pandoc-bootstrap-template/template.html " +
         " --css ~/git/pandoc-bootstrap-template/template.css " +
         " --toc " +
         " --toc-depth 2 " +
         " --data-dir=./" 
end

task :default => [:pdf] 

task :pdf => [:makeMarkdownFiles]  do
  system "cd build; pandoc --chapters --toc -s *.md -t latex -o book.pdf"
end

task :html => [:makeHtmlFiles] 

task :serve do
  system "ruby -run -e httpd -- -p 5000 ./build"
end

task :prepare do

  Mustache.template_file = 'templates/html-bootstrap/template.mustache.html'
  view = Mustache.new

  view[:items]  = [ { "name" => "topic 1"} , {"name" => "topic 2"} ]

  puts view.render
end

