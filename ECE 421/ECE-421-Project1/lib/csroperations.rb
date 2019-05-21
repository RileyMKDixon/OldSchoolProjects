require 'test/unit/assertions'

module Csroperations

    def scalar_add(value)
        # pre conditions
        assert(value.is_a?(Integer) || value.is_a?(Float), "value must be of type Number")
        pre_cols = self.cols
        pre_rows = self.rows
        pre_value = self.get_element(1, 1)

        # loop through non_zero and add the scalar
        self.iterate {|element| element + value.to_f}

        # post conditions
        assert(self.rows == pre_rows && self.cols == pre_cols, 'Matrix size modified')
    end

    def scalar_subtract(value)
        # pre conditions
        assert(value.is_a?(Integer) || value.is_a?(Float), 'value must be of type Number')
        pre_cols = self.cols
        pre_rows = self.rows
        pre_value = self.get_element(1, 1)

        # loop through entire array
        self.iterate {|element| element - value.to_f}

        # post conditions
        assert(self.rows == pre_rows && self.cols == pre_cols, 'Matrix size modified')
    end

    def scalar_multiply(value)
        # pre conditions
        assert(value.is_a?(Integer) || value.is_a?(Float), 'value must be of type Number')
        pre_cols = self.cols
        pre_rows = self.rows
        pre_value = self.get_element(1, 1)

        # loop through non-zero and multiply the scalar
        self.iterate {|element| element * value.to_f}

        # post conditions
        assert(self.rows == pre_rows && self.cols == pre_cols, 'Matrix size modified')
    end

    def scalar_divide(value)
        #preconditions
        assert(value.is_a?(Integer) || value.is_a?(Float), 'value must be of type Number')
        assert(value != 0, 'value cannot be zero')
        pre_cols = self.cols
        pre_rows = self.rows
        pre_value = self.get_element(1, 1)


        # loop through non-zero and divide the scalar
        self.iterate {|element| element / value.to_f}

        # post conditions
        assert(self.rows == pre_rows && self.cols == pre_cols, 'Matrix size modified')
    end

    def scalar_exponent(value)
        # pre conditions
        assert(value.is_a?(Integer) || value.is_a?(Float), 'value must be of type Number')
        pre_cols = self.cols
        pre_rows = self.rows
        pre_value = self.get_element(1, 1)

        # loop through non-zero and raise to the exponent of the scalar
        self.iterate {|element| element ** value.to_f}

        # post conditions
        assert(self.rows == pre_rows && self.cols == pre_cols, 'Matrix size modified')
    end

    def inverse()
        # pre conditions
        assert(self.rows == self.cols, 'Non-Square Matrix')
        assert(self.determinant() != 0, 'Zero Determinant')
        pre_matrix = self.clone
        pre_cols = pre_matrix.cols
        pre_rows = pre_matrix.rows

        # To get the inverse we need the inverse of the determinant of the sparse matrix
        # As well as the transpose of the cofactor matrix
        # We then do scalar multiplication with the two

        # to get the inverse we need to first get the sparse matrix and cofactor
        # initialize a new array with default values of zero
        new_matrix = self.to_array


        # now construct the cofactor matrix
        cofactor_matrix = Array.new(rows) {Array.new(cols, 0)}

        # now populate the cofactor matrix by getting the determinants for every element
        for row in 0...cofactor_matrix.length
            for col in 0...cofactor_matrix.length
                cofactor = get_cofactor(new_matrix, row, col, new_matrix.length)
                cofactor_det = calc_determinant(cofactor, cofactor.length - 1)

                # we need to consider which elements in the cofactor matrix need to be multiplied by a negative
                # if row is even and col is odd multiply by -1
                # likewise if row is odd and col is even multiply by -1
                if row % 2 == 0 and col % 2 == 1
                    cofactor_det = cofactor_det * -1
                elsif row % 2 == 1 and col % 2 == 0
                    cofactor_det = cofactor_det * -1
                end

                cofactor_matrix[row][col] = cofactor_det
            end
        end
        # convert cofactor matrix to csr
        csr_matrix = Csrfactory.new.csr_from_2d_array(cofactor_matrix)
        # transpose csr_matrix
        csr_matrix.transpose

        # get the determinant of self
        determinant = self.determinant()
        inv_determinant = 1.0 / determinant
        # multiply with transposed matrix
        csr_matrix.scalar_multiply(inv_determinant)

        # post conditions
        ident_matrix = Factoryproducer.get_factory('csr').create_ident_csr(self.rows)
        pre_matrix.matrix_multiply(csr_matrix)
        # because we dealt with floating point operations we need to round each element to the nearest integer
        pre_matrix.iterate {|element| element.round}

        assert(ident_matrix == pre_matrix, 'Incorrect Inverse')
        assert(csr_matrix.rows == pre_rows && csr_matrix.cols == pre_cols, 'Matrix size modified')

        # override self with csr_matrix attributes
        self.row_start = csr_matrix.row_start
        self.non_zero = csr_matrix.non_zero
        self.col_index = csr_matrix.col_index
        self.cols = csr_matrix.cols
        self.rows = csr_matrix.rows
    end

    def transpose()
        # this function will return the transposed matrix of self
        # it will not actually alter self, but just return a new matrix
        # pre conditions
        pre_matrix = self.clone
        pre_cols = pre_matrix.cols
        pre_rows = pre_matrix.rows

        # In a transposed matrix, the number of rows and columns swap
        cols = self.rows
        rows = self.cols

        # initialize a new array with default values of zero
        new_array = Array.new(rows) {Array.new(cols, 0)}

        element_index = 0
        column_counter = 0 # this is used to determine how many numbers are to be in any given column
        element_column = 0 # this is used to specify the index of the current column being populated

        for row_start_idx in 0...self.row_start.length - 1
            # set the column counter by getting the difference between
            # the element at row_start_idx and the next one in row_start array
            column_counter = self.row_start[row_start_idx + 1] - self.row_start[row_start_idx]

            # while column counter is not 0, we populate the array
            while column_counter != 0
                # get the value, column, and row of element
                element_val = self.non_zero[element_index]
                element_row = self.col_index[element_index] # gives row of transposed matrix

                # add new element to the transposed array
                new_array[element_row][element_column] = element_val

                # decrement the column counter and increment the element_index
                column_counter -= 1
                element_index += 1
            end

            element_column += 1
        end

        # convert the array to a csr matrix
        new_csr = Csrfactory.new.csr_from_2d_array(new_array)

        # post conditions
        assert(self.rows == pre_cols && self.cols == pre_rows, 'Matrix size modified')
        assert(new_csr.is_a?(Csrmatrix), 'Csr matrix not returned')

        # override properties of self to match new_csr
        self.rows = new_csr.rows
        self.cols = new_csr.cols
        self.row_start = new_csr.row_start
        self.col_index = new_csr.col_index
        self.non_zero = new_csr.non_zero
    end


    def determinant()
        # The algorithm for this function is borrowed from https://www.geeksforgeeks.org/determinant-of-a-matrix/
        # Returns the determinant of the sparse matrix
        # pre conditions
        assert(self.rows == self.cols, 'Non-Square Matrix')

        # populate 2d array
        # initialize a new array with default values of zero
        new_array = self.to_array

        # call calc_determinant
        result = calc_determinant(new_array, self.rows)

        # post conditions
        assert(result.is_a?(Integer), 'Non Numerical Result')
        return result
    end


    def matrix_add(matrix)
        # pre conditions
        assert(matrix.is_a?(Sparsematrix), 'Argument must be a Matrix')
        assert(self.rows == matrix.rows && self.cols == matrix.cols, 'Incompatible Dimensions')
        pre_value = self.get_element(1, 1)
        pre_cols, pre_rows = self.cols, self.rows
        for r in 1..matrix.rows
            for c in 1..matrix.cols
                value = self.get_element(r, c) + matrix.get_element(r, c)
                self.set_element(r, c, value)
            end
        end
        # post conditions
        assert(self.rows == pre_rows && self.cols == pre_cols, 'Matrix size modified')
        assert(self.get_element(1, 1) == (pre_value + matrix.get_element(1, 1)), 'Incorrect Value')
    end

    def matrix_subtract(matrix)
        # pre conditions
        assert(matrix.is_a?(Sparsematrix), 'Argument must be a matrix')
        assert(self.rows == matrix.rows && self.cols == matrix.cols, 'Incompatible Dimensions')
        pre_value = self.get_element(1, 1)
        pre_cols, pre_rows = self.cols, self.rows
        for r in 1..matrix.rows
            for c in 1..matrix.cols
                value = self.get_element(r, c) - matrix.get_element(r, c)
                self.set_element(r, c, value)
            end
        end
        # post conditions
        assert(self.rows == pre_rows && self.cols == pre_cols, 'Matrix size modified')
        assert(self.get_element(1, 1) == (pre_value + matrix.get_element(1, 1)), 'Incorrect Value')
    end

    def matrix_multiply(matrix)
        matrixProduct = Factoryproducer.get_factory('csr').csr_blank(self.rows, matrix.cols)
        # pre conditions
        assert(matrix.is_a?(Sparsematrix), 'Argument must be a matrix')
        assert(matrixProduct.is_a?(Sparsematrix), "2nd Argument must be an empty sparse matrix")
        assert(self.cols == matrix.rows, 'Incompatible Dimensions')

        #For each row in the product matrix
        for matrixProductRows in 1...matrixProduct.rows+1
            #For each column in the product matrix
            for matrixProductColumns in 1...matrixProduct.cols+1
                #variable to hold the resulting value for the product matrix element
                #currently being operated on.
                currentElement = 0

                #Go along the row of the calling matrix
                #And get the corresponding element from the column of the
                #second matrix.
                for matrixProductCurrent in self.row_start[matrixProductRows-1]...self.row_start[matrixProductRows]
                    currentElement += self.non_zero[matrixProductCurrent] * matrix.get_element(self.col_index[matrixProductCurrent]+1, matrixProductColumns)
                end 

                #Set the final value for the specific element.
                matrixProduct.set_element(matrixProductRows, matrixProductColumns, currentElement)
            end
        end

        #Put the product matrix back into the calling matrix
        self.rows = matrixProduct.rows
        self.cols = matrixProduct.cols
        self.row_start = matrixProduct.row_start
        self.col_index = matrixProduct.col_index
        self.non_zero = matrixProduct.non_zero

        # post conditions
        assert(self.rows == matrixProduct.rows && matrix.cols == matrixProduct.cols, 'Incorrect Resulting Dimensions')
    end

    def matrix_divide(matrix)
        # Calculates self * matrix' (inverse)
        # pre conditions
        assert(matrix.is_a?(Sparsematrix), 'Argument must be a matrix')
        assert(matrix.rows == matrix.cols, 'Divisor must be a square matrix')
        det = matrix.determinant()

        assert(det != 0, 'Divisor cannot have Zero-determinant')

        # post conditions
        divisor = matrix.clone
        
        ret = matrix_multiply(divisor.inverse)
        assert(ret.cols == matrix.cols && ret.rows == @rows, 'Incompatible Dimensionality')

        # override self with returned value
        self.row_start = ret.row_start
        self.non_zero = ret.non_zero
        self.col_index = ret.col_index
        self.rows = ret.rows
        self.cols = ret.cols
    end

    private
    def get_cofactor (arr, element_row, element_col, size)
        # this function is used in calculating determinants of matrices
        row_idx = 0
        col_idx = 0
        cofactors = Array.new(self.rows) {Array.new(self.cols, 0)}

        for row in 0...size # size for current matrix
            for col in 0...size
                # need to grab all elements that are not in a given element's
                # row and column. Put them in temporary array
                if row != element_row and col != element_col
                    cofactors[row_idx][col_idx] = arr[row][col]
                    col_idx += 1


                    # when row is filled increase row_index and decrease col_index
                    if col_idx == size - 1
                        col_idx = 0
                        row_idx += 1
                    end

                    # at the end, temp array will have the cofactor
                end
            end
        end
        return cofactors
    end

    def calc_determinant(arr, size)
        # this function calculates the determinant of an array
        # recursion is used for this and the algorithm was borrowed from
        # https://www.geeksforgeeks.org/determinant-of-a-matrix/
        # arr is the matrix to be solved, cofactors is a temp array
        # to hold cofactors, size is the size of the current matrix

        result = 0
        sign = 1 # alternating signs are required when calculating determinant

        # if a matrix contains a single element, return the element
        if size == 1
            return arr[0][0]
        end

        for idx in 0...size
            cofactors = get_cofactor(arr, 0, idx, size)
            # at this point the cofactor will be saved in cofactors array
            # recursively add the result
            result += sign * arr[0][idx] * calc_determinant(cofactors, size - 1)

            # switch the sign
            sign = -sign
        end

        return result
    end
end
