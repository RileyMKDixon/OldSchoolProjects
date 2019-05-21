require_relative 'token.rb'

require "test/unit"

class Player

    attr_reader :win_conditions, :title


    def initialize(title, color, win_conditions)
        assert(win_conditions.is_a?(Array))

        @color = color
        @title = title
        @win_conditions = []  # Do we need this?

        win_conditions.each do |cond|
            assert(cond.is_a?(String))
            # we also want  to add the reverse of each condition to the player win_conditions
            @win_conditions.push(cond)
            if cond.reverse != cond
                @win_conditions.push(cond.reverse)
            end

        end

        # assert_false(color.nil?)  UNCOMMENT LATER


    end

    def generate_token()
        
        return Token.new(@color, @title)
        # Return token that is of type <type>
    end
end