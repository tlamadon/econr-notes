

BOOK_CONTENT = [
  "Intro",
  "chapter1",
  "DataTable",
  "savingRcppGSL",
  "FortranAndR",
  "BlitzExample"
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
HTML_FILES     = BOOK_CONTENT.collect { |fs| File.join(OBJDIR, File.basename(fs).ext('htmlfrag')) }

# CLEAN.include(MARKDOWN_FILES)
# CLEAN.include(HTML_FILES)
# CLEAN.include("build/book.pdf")
CLEAN.include(OBJDIR)

# task that processes all Rmd files
task :makeMarkdownFiles     => MARKDOWN_FILES
task :makeHtmlFiles         => HTML_FILES

# INITIALIZE BUILD DIRECTORY
# ==========================
directory OBJDIR

# FILE PROCESSING RULES
# =====================

# RMD  =>   MD
# -------------------------
rule '.md' => [ proc { |tn| File.join(SRCDIR, File.basename(tn).ext('Rmd')) },'%d'] do |t|
    system "cd build; Rscript -e \"options(encoding='UTF-8'); require(knitr); knit('../#{t.source}');\""
end

# COPY MARKDOWN => BUILD
# -------------------------
rule /build.*.md/ => [ proc { |tn| File.join(SRCDIR, File.basename(tn).ext('md')) },'%d'] do |t|
    system "cp #{t.source} #{t.name}"
end

# MARKDOWN => HTML FRAGMENT
# -------------------------
rule '.htmlfrag' => '.md' do |t|
  #system "pandoc --mathjax -s #{t.source} -t html -o #{t.name}"
  system "pandoc --mathjax #{t.source}" +
         " -o #{t.name} " +
         " --data-dir=./" 
end

# GENERAL TASKS
# =============

task :default => [:pdf] 

task :pdf => [:makeMarkdownFiles]  do
  system "cd build; pandoc --chapters --toc -s *.md -t latex -o book.pdf"
end

task :html => [:makeHtmlFiles,:prepare] do
  system "cp -rf lib/* #{OBJDIR}"
end

task :serve do
  system "ruby -run -e httpd -- -p 5000 ./build"
end


# TESTING
# =======


task :prepare do

  Mustache.template_file = 'templates/html-bootstrap/template.mustache.html'
  view = Mustache.new

  for chap in BOOK_CONTENT
      data = File.open("build/" + chap + ".htmlfrag", "rb") {|io| io.read}

      view = Mustache.new
      view[:items]  = [ { "name" => "topic 1"} , {"name" => "topic 2"} ]
      view[:chaps]  = [ { "name" => "DataTable", "link" => "DataTable.html"} , 
                        { "name" => "Consumption Saving Model", "link" => "savingRcppGSL.html"},
                        { "name" => "Blitz Example", "link" => "BlitzExample.html"},
                        { "name" => "Fortran And R", "link" => "FortranAndR.html"} ]
      view[:content] = data

      File.open("build/" + chap + ".html", 'w') { |file| file.write(view.render) }
  end

end

