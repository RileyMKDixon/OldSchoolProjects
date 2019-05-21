require_relative 'sparsematrix.rb'
require_relative 'dokoperations.rb'

class Dokmatrix < Sparsematrix
    include Dokoperations

    attr_reader :rows, :cols, :dict

    def initialize(rows, cols, dict)
        # Invariant:
            # dict.is_a?(hash) == true
        super(rows, cols)
        @dict = dict
    end

    def property
        [@rows, @cols, @dict]
    end

    def each_non_zero
        @dict.each_value do |val|
            yield val
        end
    end

    def each_with_index
        @dict.each do |key, val|
            yield key << val
        end
    end

    def each_with_zero
        for i in 0..@rows-1
            for j in 0..@cols-1
                yield get_element(i, j)
            end
        end
    end

    def each_with_zero_with_index
        for i in 0..@rows-1
            for j in 0..@cols-1
                key = [i, j]
                val = get_element(i, j)
                yield key << val
            end
        end
    end

    def set_element(rows, cols, value)
        assert(rows <= @rows, 'row exceeds max rows')
        assert(rows > 0, "Row is less than 0")
        assert(cols <= @cols, 'col exceeds max cols')
        assert(cols > 0, "Col is less than 0")
        dokKey = [rows, cols]
        @dict[dokKey] = value
        if @dict[dokKey] == 0
            @dict.delete(dokKey)
        end
    end

    def get_element(rows, cols)
        assert(rows <= @rows, 'row exceeds max rows')
        assert(rows > 0, "Row is less than 0")
        assert(cols <= @cols, 'col exceeds max cols')
        assert(cols > 0, "Col is less than 0")
        dokKey = [rows, cols]
        return @dict[dokKey]
    end

    def sparcity
        totalNumOfElements = @rows * @cols
        totalNumOfNonZeroElements = @dict.length
        return totalNumOfNonZeroElements/totalNumOfElements.to_f
    end
end