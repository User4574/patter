module Patter
  class Var; end

  class Fun
    def self.find(name)
      return $patter_funs[name]
    end

    def initialize(name)
      $patter_funs = {} unless $patter_funs
      @patterns = {}
      $patter_funs[name] = self
    end

    def when(*args, &block)
      raise "Block arity does not match number of free variables" if args.count(Var) != block.arity
      @patterns[args] = block
    end

    def call(*args)
      free_vars, block = match(args)
      block.call(*free_vars)
    end

    alias_method :[], :call

    private

    def match(args)
      @patterns.each do |pattern, block|
        next if pattern.length != args.length
        free_variables = []
        matched = true
        pattern.zip(args).each do |pair|
          if pair.first == Var then
            free_variables << pair.last
            next
          end
          if pair.first != pair.last then
            matched = false
            break
          end
        end
        return [free_variables, block] if matched
      end
      raise "Inexhaustive patterns"
    end
  end

  def method_missing(name, *args)
    if $patter_funs && $patter_funs.include?(name) then
      $patter_funs[name].call(*args)
    end
  end
end
