module Kernel
  def p80(*args)
    File.open("/tmp/wiki.log", "w") do |f|
      f.puts '*' * 80
      args.each {|arg| f.puts arg}
      yield(f) if block_given?
      f.puts '*' * 80
    end
  end
end