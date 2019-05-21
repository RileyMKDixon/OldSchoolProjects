require_relative 'dokmatrix.rb'
require_relative 'csrmatrix.rb'
require 'matrix'

include Test::Unit::Assertions

class Dokfactory

    def dok_blank(rows, cols)
        # pre conditions
        # rows, cols, int >= 0
        assert(rows > 0, "Bad Row Count")
        
        # post condition
        dict = Hash.new(0)
        return Dokmatrix.new(rows, cols, dict)
    end

    def dok_from_2d_array(array)
        # pre conditions
        # array is an array of equisized arrays
        assert(array.is_a?(Array), 'Bad Argument Supplied')

        dict = Hash.new(0)
        cols = array[0].size

        array.each_with_index do |rowarray, row|

            assert(cols == rowarray.size, "Inconsistent Matrix Dimensions")

            rowarray.each_with_index do |item, col|
                if item != 0
                    dict[[row+1, col+1]] = item
                end
            end
        end
        return Dokmatrix.new(array.size, cols, dict)
        # post conditions
        # dokmatrix representing the two-d array
    end

    def dok_from_matrix(matrix)
        # pre conditions
        # matrix is a ruby matrix
        assert(matrix.is_a?(Matrix), 'Bad Argument Supplied')

        dict = Hash.new(0)

        matrix.each_with_index do |item, row, col|
            if item != 0
                dict[[row+1, col+1]] = item
            end
        end

        return Dokmatrix.new(matrix.row_count(), matrix.column_count, dict)
    end

    def dok_from_csr(csr)
        # pre conditions
        # csr is a valid csrmatrix
        assert(csr.is_a?(Csrmatrix), "Matrix must be a Csrmatrix")
        # post conditions
        # dokmatrix representing the csr matrix
        csrProperties = csr.property
        csrRows = csrProperties[0]
        csrColumns = csrProperties[1]
        csrElementList = csrProperties[2]
        csrRowOffset = csrProperties[4]
        csrColumnOffset = csrProperties[3]

        dokMatrix = Dokfactory.new.dok_blank(csrRows, csrColumns)

        for currentRow in 1...csrRows+1
            #For each row in the "real" matrix
            #Helps with the ranges of the matrices for CSR
            for currentElementPos in csrRowOffset[currentRow - 1]...csrRowOffset[currentRow]
                dokMatrix.set_element(currentRow, csrColumnOffset[currentElementPos]+1, csrElementList[currentElementPos])
                #Using the current range (currentElementPos) as the array element position, grab the
                #value of the element and the column that it belongs to
            end
        end
        #Post condition
        #[10...-1] skips the header line that prints the type of matrix
        assert_equal(csr.to_s[10...-1], dokMatrix.to_s[10...-1])
        return dokMatrix
    end
end
