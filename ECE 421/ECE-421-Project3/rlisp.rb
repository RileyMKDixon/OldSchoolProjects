class RLisp

    def initialize()
        @operators = [:label, :quote, :car, :cdr, :cons, :eq, :if, :atom, :lambda]
        @labels = Hash.new()
    end

    def eval(exp)
        if !exp.instance_of?(Array)
            if @values.include?(exp)
                return @values[exp]
            elsif exp.is_a?(Numeric)
                return exp
            else
                return nil
            end

        elsif !(@operators.include?(exp[0]))
            p "Not valid Lisp"
            return nil

        elsif exp[0] == :label
            if !exp[1].instance_of?(Symbol)
                p "Cannot assign value to non-symbol"
            elsif @operators.include?(exp[1])
                p "Cannot overwrite symbol " + exp[1].to_s
            else
                @labels[exp[1]] = eval(exp[2])
            end

        elsif exp[0] == :eq
            if exp.size != 3
                p "Invalid syntax for :eq, requires size 3"
                return nil
            end
            return eval(exp[1]) == eval(exp[2])

        elsif exp[0] == :quote
            if exp.size != 2
                p "Invalid syntax for :quote, requires size 2"
                return nil
            end
            return exp[1]

        elsif exp[0] == :car
            if exp.size != 2
                p "Invalid syntax for :car, requires size 2"
                return nil
            elsif !exp[1].instance_of?(Array)
                p ":car requires an array"
                return nil
            else return eval(exp[1])[0]
            end

        elsif exp[0] == :cdr
            if exp.size != 2
                p "Invalid syntax for :cdr, requires size 2"
                return nil
            elsif !exp[1].instance_of?(Array)
                p ":cdr requires an array"
                return nil
            else return eval(exp[1])[1..-1]
            end

        elsif exp[0] == :cons
            if exp.size != 3
                p "Ivalid syntax for :cons, requires size 3"
                return nil
            elsif exp[1].is_a?(Numeric) || exp[1].is_a?(Array)
                ret = Array.new()
                ret << exp[1]
                return ret.concat(eval(exp[2]))
            end

        elsif exp[0] == :if
            if exp.size != 4
                p "Invalid syntax for :if, requires size 4"
                return nil
            end
            if (eval(exp[1]))
                return eval(exp[2])
            else
                return eval(exp[3])
            end

        elsif exp[0] == :atom
            if exp.size != 2
                p "Invalid syntax for :atom, requires size 2"
                return nil
            end
            return eval(exp[1]).is_a?(Numeric)
            
        elsif exp[0] == :lambda
            # [[:lambda, [params], [body]], param_values]
            # create a lambda function which takes params in params and executes body with those params
            # How do I do this properly?
            # Subclass, or defined structure
            # 
            if exp.size != 3
                p "Invalid syntax for :lambda, requires size 3"
                return nil
            elsif eval(exp[3]).size != exp[1].size
                p "Invalid amount of arguments for this lambda expression"
            else
                tmp_dict = Hash.new
                exp[1].each do |lbl|
                    # tmp_dict[lbl] =
                end
            end 
        end
    end
end

l = RLisp.new
p l.eval 3
p :eval
l.eval [:label, :x, 15]
l.eval [:label, :if, 1]
p l.eval :x
p :eq
p l.eval [:eq, 17, :x]
p l.eval [:eq, 15, :x]
p :quote
p l.eval [:eq, [:quote, [3, 6]], [:quote, [3, 6]]]
p l.eval [:quote, [7, 10, 12]]
p :cadr
p l.eval [:car, [:quote, [7, 10, 12]]]
p l.eval [:cdr, [:quote, [7, 10, 12]]]
# p l.eval [:car, [:car, [:cdr, [:quote, [7, [10, 12]]]]]]
p :cons
p l.eval [:cons, 5, [:quote, [7, 10, 12]]]
p :atom
p l.eval [:atom, [:quote, [7, 10, 12]]]
p l.eval [:atom, :x]
p l.eval [:atom, 5]
p :if
p l.eval [:if, [:eq, 5, 7], 6, 7]