require_relative 'sparsematrix.rb'
require_relative 'csroperations.rb'
require 'set'

class Csrmatrix < Sparsematrix
    include Csroperations

    # Specifically store a sparse matrix in Compressed Space Row format
    # constructor(s), sparsity?
    # attributes for size

    attr_accessor :non_zero, :col_index, :row_start, :rows, :cols

    def initialize(rows, cols, non_zero, col_index, row_start)
        # Invariant:
            # non_zero.is_a?(array) == true
            # col_index.is_a?(array) == true
            # row_start.is_a?(array) == true
            # non_zero.count >= 0
            # col_index.count >= 0
            # row_start.count > 0
            # non_zero.size == col_index.size
            # row_start.size == rows + 1
        super(rows, cols)
        @non_zero = non_zero
        @col_index = col_index
        @row_start = row_start
    end

    # iterate method applies some operation across all values in the matrix.
    # It does not iterate through the values in order, but rather the non-zero
    # elements first
    #
    # Usage: multiplying every value in the matrix by 2
    # iterate {|n| n*2}
    # Usage: replaceing all values by 10
    # iterate {|n| 10}
    def iterate()
        return nil unless block_given?
        looked_up = []
        dead_values = {}
        for r in 0...@rows
            for i in @row_start[r]...@row_start[r+1]
                value = @non_zero[i]
                c = @col_index[i]
                looked_up << [r, c]
                yield_result = yield(value)
                if yield_result  != 0
                    @non_zero[i] = yield_result
                else
                    if not dead_values.key?(r + 1)
                        dead_values[r + 1] = 0
                    end
                    dead_values[r + 1] += 1
                    @non_zero[i] = 'dead'
                    @col_index[i] = 'dead'
                end
            end
        end
        @non_zero.delete('dead')
        @col_index.delete('dead')
        for k in dead_values.keys
            for i in k...@row_start.length
                @row_start[i] -= dead_values[k]
            end
        end
        looked_up = Set.new(looked_up)
        for r in 0...@rows
            for c in 0...@cols
                yield_result = yield(0)
                if (not looked_up.member?([r, c])) and yield_result != 0
                    set_element(r + 1, c + 1, yield_result)
                end
            end
        end
    end

    def element_exists(row, col)
        assert(row <= @rows, 'row exceeds max rows')
        assert(row > 0, "Row is less than 0")
        assert(col <= @cols, 'col exceeds max cols')
        assert(col > 0, "Col is less than 0")
        for i in @row_start[row - 1]...@row_start[row]
            if @col_index[i] == col - 1
                return [i, row]
            end
        end
        return false
    end

    def update_row_start(indx, value)
        for i in indx...@row_start.length
            @row_start[i] += value
        end
    end

    def set_element(row, col, replacement)
        assert(row <= @rows, 'row exceeds max rows')
        assert(row > 0, "Row is less than 0")
        assert(col <= @cols, 'col exceeds max cols')
        assert(col > 0, "Col is less than 0")
        # check if it exists already
        find = element_exists(row, col)
        if find
            if replacement == 0
                update_row_start(find[1], -1)
                @non_zero.delete_at(find[0])
                @col_index.delete_at(find[0])
            else
                @non_zero[find[0]] = replacement
            end
        else
            if replacement != 0
                min, max = @row_start[row - 1], @row_start[row]
                new_value = [[replacement, col - 1]]
                for i in min...max
                    new_value << [@non_zero[i], @col_index[i]]
                end
                mid_non_zero, min_col_idx = [], []
                new_value.sort_by(&:last).each do |v|
                    mid_non_zero << v[0]
                    min_col_idx << v[1]
                end
                @non_zero = @non_zero[0...min] + mid_non_zero + @non_zero[max...@non_zero.length]
                @col_index = @col_index[0...min] + min_col_idx + @col_index[max...@col_index.length]
                update_row_start(row, 1)
            end
        end
    end

    def get_element(row, col)
        result = 0
        find = element_exists(row, col)
        if find
            result = @non_zero[find[0]]
        end
        result
    end

    def property
        [@rows, @cols, @non_zero, @col_index, @row_start]
    end

    def ==(matrix)
        self.class == matrix.class and self.property == matrix.property
    end

    def each_non_zero
        @non_zero.each do |element| # iterator for non zero array
            yield(element)
        end
    end

    def each_row_start
        @row_start.each do |element| # iterator for non zero array
            yield(element)
        end
    end

    def sparcity
        totalNumOfElements = @rows * @cols
        totalNumOfNonZeroElements = @non_zero.length
        return totalNumOfNonZeroElements/totalNumOfElements.to_f
    end
end

