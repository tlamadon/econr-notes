


# BOOK_CONTENT = [
#   "Intro",
#   "chapter1",
#   "DataTable",
#   "savingRcppGSL",
#   "FortranAndR",
#   "BlitzExample"
# ]

# define a function that extracts the TOC
# just pasrse the files and collect whatever
# starts with # (any number of them) and collect 
# the links.
require 'rake/clean'
require 'mustache'
require './conf/utils.rb'

BOOK_INDEX = load_book_structure('chapters.json')
BOOK_CONTENT = []
for chap in BOOK_INDEX["chapters"]
  for section in chap["content"]
    BOOK_CONTENT << section["key"]
  end
end

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

# RMD  =>   MD  (  chap.md depends on cha.Rmd)
# --------------------------------------------
rule '.md' => [ proc { |tn| File.join(SRCDIR, File.basename(tn).ext('Rmd')) },'%d'] do |t|
    system "cd build; Rscript -e \"options(encoding='UTF-8'); require(knitr); knit('../#{t.source}');\""
    system "sed -i '' 's/\$latex/\$/g' #{t.name}"
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

task :clean_html do
  system "rm -rf ./build/*.html"
end

task :publish do
  system "rsync"
end
# TESTING
# =======

task :prepare do

  Mustache.template_file = 'content/index.htmlfrag'
  view = Mustache.new
  view[:items]         = BOOK_INDEX["chapters"]
  view[:contributors]  = get_contributors()
  view[:navfixed]      = false
  File.open("build/" + "index.htmlfrag", 'w') { |file| file.write(view.render) }

  Mustache.template_file = 'templates/html-bootstrap/template.mustache.html'

  # process book content
  for chap in BOOK_INDEX["chapters"]
    print "generating #{chap['title']}\n"
    for section in chap["content"] 
      view = Mustache.new
      print "generating >> #{section['title']}\n"
      view[:navfixed]      = true
      view[:items]  = BOOK_INDEX["chapters"]
      view[:chaps]  = BOOK_INDEX["chapters"]
      view[:show_toc] = true
      process_section(view, section["key"])      
    end        
  end

  view = Mustache.new
  print "generating >> index.html\n"
  view[:items]  = BOOK_INDEX["chapters"]
  view[:chaps]  = BOOK_INDEX["chapters"]
  view[:show_toc] = false
  process_section(view, "index")      

end

