require 'rubygems'
require 'mustache'
require 'json'
require 'pp'
require 'open-uri'

def process_section(view, section_key)
  data = File.open("build/" + section_key + ".htmlfrag", "rb") {|io| io.read}
  view[:content] = data
  File.open("build/" + section_key + ".html", 'w') { |file| file.write(view.render) }
end

def load_book_structure(file_name) 
  json  = File.read(file_name)
  index = JSON.parse(json)
  return index
end

def get_contributors()
  str = open("https://api.github.com/repos/tlamadon/econr-notes/contributors") {|f|  #url must specify the protocol
    str = f.read()
  }
  return JSON.parse(str)
end



# def extract_toc(section_key)
#   toc = []
#   File.each_line(section_key + '.htmlfrag') do |li|
    


#     puts li if (li['ohn'])


#   end
# end