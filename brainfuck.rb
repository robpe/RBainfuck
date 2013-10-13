# 
# Brainfuck interpreter written in ~1h (ended up with quick and dirty hacks)

# monkey patch for nil class (nil acts as zero)
module NilZero
  def +(n) ; n ; end
  def zero? ; true ; end
end


# pushing bytes from file to array only when we need it
class LazyStream < Array
  def initialize(filename)
    @input = File.open(filename, 'r')
  end

  # dirty hack - we don't use 
  def [](i)
    until self.at(i) ; self << @input.getc ; end
    self.at(i)
  end
end

class Brainfuck < Array
  
  nil.extend NilZero 

  def self.run(filename)
    new(LazyStream.new(filename)).evaluate
  end

  def initialize(stream)
    @code = stream
    super
  end

  def evaluate
    returns = []
    pointer = instruction = 0
    while c = @code[instruction]
      case c
      when '>' ; pointer+=1
      when '<' ; pointer-=1
      when '+' ; self[pointer] +=1 
      when '-' ; self[pointer] -=1
      when '.' ; putc self[pointer].chr
      when ',' ; self[pointer] = STDIN.getc.ord
      when '[' 
        returns << instruction
        if self[pointer].zero?
          pars = 1
          until pars.zero?
            instruction += 1
            @code[instruction].eql?(']') && pars-=1
            @code[instruction].eql?('[') && pars+=1 
          end
          returns.pop
        end
      when ']'
        instruction = self[pointer].zero? ? (returns.pop ; instruction) : returns.last
      else
        break
      end
      instruction+=1
    end

  end
end


if __FILE__ == $0
  Brainfuck.run(ARGV.first)
end
