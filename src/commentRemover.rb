

# To run: 
#   ruby -w -W commentRemover.rb <filename> [java|ruby] outputFile
# 

fileToCleanupComments = ARGV.shift
language = ARGV.shift || "ruby"
outputFile = ARGV.shift || "fileWithoutComments.out"
fileContents = File.read( fileToCleanupComments )
case language
when "ruby"   
    # ignores #+ within strings and within regex (/.../):
    fileContents.gsub!(/(^\s*#.+)|([^"'%]#(?!({|.+["'\/])).*)/, "")   # for Ruby
when "java"
    fileContents.gsub!(/\/\*.*\*\//m, "")       # for "/*...*/" style comments in Java
    fileContents.gsub!(/\/\/(?!{).*/, "")       # for "//" style comments in Java
when "Your favorite language"
    fileContents.gsub!(/regex describing comments to be removed/, "")
else
    raise "Unknown given language '#{language}'"
end
File.open( outputFile, 'w') {|f| f.write( fileContents ) }

