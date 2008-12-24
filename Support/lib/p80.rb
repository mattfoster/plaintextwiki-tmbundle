module Kernel
  def p80(*args)
    puts '*' * 80
    args.each {|arg| p arg}
    yield if block_given?
    puts '*' * 80
  end
end