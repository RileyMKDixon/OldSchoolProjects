class Token

    attr_reader :owner, :color

    def initialize(color, owner)
        @color = color
        @owner = owner

    end

    def to_s
        return @owner
    end
end