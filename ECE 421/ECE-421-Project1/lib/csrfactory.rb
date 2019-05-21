require_relative 'csrmatrix.rb'

require_relative 'dokfactory.rb'
require_relative 'dokmatrix.rb'


require "test/unit"
require 'matrix'
include Test::Unit::Assertions

class Csrfactory

    def csr_blank(rows, cols)
        # pre conditions
        # rows, cols, int >= 0
        #
        # post condition
        # csrmatrix, all 0, of size rows x cols
        return Csrmatrix.new(rows, cols, Array.new, Array.new, Array.new(rows + 1, 0))
    end

    def csr_from_2d_array(array)
        # pre conditions
        assert(array.is_a?(Array), 'Bad Argument Supplied')
        non_zero = Array.new
        col_index = Array.new
        row_start = [0]
        cols = 0
        row_counter = 0
        array.each do |subarray|
            col_counter = 0
            value_counter = 0
            subarray.each do |i|
                if i != 0
                    non_zero << i
                    col_index << col_counter
                    value_counter += 1
                end
                col_counter += 1
                cols = col_counter
            end
            row_counter += 1
            row_start << row_start[row_counter - 1] + value_counter
        end
        # post conditions
        # csrmatrix representing the two-d array
        Csrmatrix.new(row_counter, cols, non_zero, col_index, row_start)
    end

    def csr_from_matrix(matrix)
        # pre conditions
        # matrix.is_a?(matrix)
        assert(matrix.is_a?(Matrix), 'Argument must be a Ruby Matrix\n')
        non_zero = Array.new
        col_index = Array.new
        row_start = [0]
        cols = 0
        row_counter = 0
        row_vectors = matrix.row_vectors() # row_vectors() returns an array of the rows of the matrix
        row_vectors.each do |vector|
            col_counter = 0
            value_counter = 0
            vector.each do |i|
                if i != 0
                    non_zero << i
                    col_index << col_counter
                    value_counter += 1
                end
                col_counter += 1
                cols = col_counter
            end

            row_counter += 1
            row_start << row_start[row_counter - 1] + value_counter
        end

        # post condition
        # csrmatrix representing the ruby matrix
        Csrmatrix.new(row_counter, cols, non_zero, col_index, row_start)

    end

    def csr_from_csr(csr)
        # pre conditions
        assert(csr.is_a?(Csrmatrix), 'Argument must be Csr Matrix')
        property = csr.property
        Csrmatrix.new(property[0], property[1], property[2].dup, property[3].dup, property[4].dup)
        # copy of csr
    end

    def csr_from_dok(dok)
        # pre conditions
        # dok is a valid dokmatrix
        assert(dok.is_a?(Dokmatrix), "Argument must be a Dokmatrix")
        #
        # post conditions
        # csrmatrix representing the dok matrix

        #Copy the properties of the Dokmatrix to create the csrMatrix
        dokProperties = dok.property
        dokRows = dokProperties[0]
        dokColumns = dokProperties[1]
        dokDict = dokProperties[2]

        csrMatrix = Csrfactory.new.csr_blank(dokRows, dokColumns)

        #Go through each element in dok and use the key to set the
        #value in place.
        dokDict.each{ |key, value|
            elementRow = key[0]
            elementCol = key[1]
            csrMatrix.set_element(elementRow, elementCol, value)
            valueInMatrix = csrMatrix.get_element(elementRow, elementCol)
        }
        #Post Condition
        #[10...-1] skips the header line that prints the type of matrix

        assert_equal(dok.to_s[10...-1], csrMatrix.to_s[10...-1])

        return csrMatrix
    end

    def create_ident_csr(size)
        # pre conditions
        # size >= 1
        # assert(size > 1, 'Invalid size entered')
        assert(size > 0, 'Size must be greater than 0')
        row_start = [0]
        col_indx = []
        row_values = []
        for i in 0...size
            row_values << 1
            col_indx << i
            row_start << i + 1
        end
        Csrmatrix.new(size, size, row_values, col_indx, row_start)
        # result = Csrmatrix().new # placeholder
        # # post condition
        # # identify matrix of (rows, cols), (size, size)
        # assert(result.rows == size, 'Returned matrix with invalid number of rows')
        # assert(result.cols == size, 'Returned matrix with invalid number of columns')
    end
end
