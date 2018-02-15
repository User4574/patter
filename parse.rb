def sub_vars(string)
  outvars = []
  blockvars = []
  notvars = %w(true false nil)
  vars = string.split(",").map(&:strip)
  vars.each do |var|
    if var =~ /[a-z_][a-zA-Z0-9_]*?/ && !notvars.include?(var) then
      outvars << "Patter::Var"
      blockvars << var
    else
      outvars << var
    end
  end
  return outvars.join(", "), blockvars.join(", ")
end

def sub_funs(string, funs)
  funs.each do |fun|
    string.gsub!(/#{fun}\((.*?)\)/, "#{fun}.call(\\1)")
  end
  return string
end

lines = $stdin.readlines.map(&:chomp)
funs = []

puts "require './patter'"
puts

lines.each do |line|
  if line =~ /\s*([a-z_][a-zA-Z0-9_]*?)\((.*)\) is\s*$/ then
    unless funs.include?($1) then
      funs << $1
      puts "#{$1} = Patter::Fun.new"
    end
    arg, blk = sub_vars($2)
    if blk.empty? then
      puts "#{$1}.when(#{arg}) do"
    else
      puts "#{$1}.when(#{arg}) do |#{blk}|"
    end
  else
    puts sub_funs(line, funs)
  end
end
