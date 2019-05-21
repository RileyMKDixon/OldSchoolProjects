class Sparsematrix

    def initialize(rows, cols)
        # Invariant:
            # rows > 0
            # cols > 0
        @rows = rows
        @cols = cols
    end

    def to_s
        # Change matrix to string for printing
        ret = "#{self.class}\n[ "
        for i in 1..@rows
            if i != 1
                ret << "]\n[ "
            end
            for j in 1..@cols
                ret << get_element(i, j).to_s << " "
            end
        end
        ret << "]"
        ret
    end

    def to_array
        ret = Array.new(@rows) { Array.new(@cols, 0) }
        for i in 1..@rows
            for j in 1..@cols
                ret[i-1][j-1] = get_element(i, j)
            end
        end
        ret
    end
            

    def dimensions
        return [rows, cols]
    end
end