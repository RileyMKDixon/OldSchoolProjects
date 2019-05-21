require 'test/unit'
require_relative '../lib/factoryproducer'

class CsrOperationTests < Test::Unit::TestCase


  def setup
    @test_scalar_matrix = Factoryproducer.get_factory('csr').csr_from_2d_array([[2, 2], [2, 2]])

    @result_scalar_matrix = Factoryproducer.get_factory('csr').csr_from_2d_array([[4, 4], [4, 4]])
  end

  #------This Code Does not work ATM, I dont know why

  def test_scalar_add()
    @test_scalar_matrix.scalar_add(2)
    assert_true(@test_scalar_matrix == @result_scalar_matrix, 'Scalar Addition Failed')
  end


  def test_scalar_subtract()
    val = -2
    @test_scalar_matrix.scalar_subtract(val)
    assert_true(@test_scalar_matrix == @result_scalar_matrix, 'Scalar Subtraction Failed')
  end

  def test_scalar_multiply()
    @test_scalar_matrix.scalar_multiply(2)
    assert_true(@test_scalar_matrix == @result_scalar_matrix, 'Scalar Multiply Failed')
  end

  def test_scalar_divide()
    @test_scalar_matrix.scalar_divide(0.25)
    assert_true(@test_scalar_matrix == @result_scalar_matrix, 'Scalar Divide Failed')
  end

  def test_scalar_exponent()
    @test_scalar_matrix.scalar_exponent(2)
    assert_true(@test_scalar_matrix == @result_scalar_matrix, 'Scalar Exponent Failed')
  end

  def test_inverse()
    actual = Factoryproducer.get_factory('csr').csr_from_2d_array([[1, 2], [3, 4]])
    expected = Factoryproducer.get_factory('csr').csr_from_2d_array([[-2, 1], [1.5, -0.5]])
    assert_equal(expected, actual, "Matrix Inversion Failed")
  end

  def test_transpose()
    actual = Factoryproducer.get_factory('csr').csr_from_2d_array([[1, 2, 3, 4], [5, 6, 7, 8]])
    expected = Factoryproducer.get_factory('csr').csr_from_2d_array([[1, 5], [2, 6], [3, 7], [4, 8]])
    assert_equal(expected, actual, "Matrix Transpose Failed")
  end

  def test_determinant()
    actual = Factoryproducer.get_factory('csr').csr_from_2d_array([[1, 2], [3, 4]])
    actual.determinant()
    expected = -2
    assert_equal(expected, actual, "Matrix Determinant Calculation Failed")
  end

  def test_rref()


  end

  def test_matrix_add()
    @test_scalar_matrix.matrix_add(@result_scalar_matrix)
    expected = Factoryproducer.get_factory('csr').csr_from_2d_array([[6, 6], [6, 6]])
    assert_equal(expected, @test_scalar_matrix, "Matrix addition Failed")
  end

  def test_matrix_subtract()
    @test_scalar_matrix.matrix_subtract(@result_scalar_matrix)
    expected = Factoryproducer.get_factory('csr').csr_from_2d_array([[-2, -2], [-2, -2]])
    assert_equal(expected, @test_scalar_matrix, "Matrix subtraction Failed")
  end

  def test_matrix_multiply()
    #@test_scalar_matrix.matrix_multiply(@result_scalar_matrix)
    #expected = Factoryproducer.get_factory('csr').csr_from_2d_array([[16, 16], [16, 16]])
    #assert_equal(expected, @test_scalar_matrix, "Matrix multiplication Failed")

    
    matrix1 = Factoryproducer.get_factory('csr').csr_from_matrix(Matrix[[1, 2, -1],[2, 0, 1]])
    matrix2 = Factoryproducer.get_factory('csr').csr_from_matrix(Matrix[[3, 1], [0, -1], [-2, 3]])
    matrix3 = matrix1.matrix_multiply(matrix2)
    puts matrix3

    
  end

  def test_matrix_divide()
    matrix = Factoryproducer.get_factory('csr').csr_from_2d_array([[1, 2], [3, 4]])
    @test_scalar_matrix.matrix_divide(matrix)
    expected = Factoryproducer.get_factory('csr').csr_from_2d_array([[-1, 1], [-1, 1]])
    assert_equal(expected, @test_scalar_matrix, "Matrix Division Failed")

  end

  def test_csr_from_dok()
    matrixValues = Matrix[[1, 0, 3, 6], [1, 5, 3, 12], [7, 0, 9, -6]]
    dokMatrix = Factoryproducer.get_factory('dok').dok_from_matrix(matrixValues)
    csrMatrix = Factoryproducer.get_factory('csr').csr_from_dok(dokMatrix)
    
    #puts csrMatrix.to_s[10...-1] <-Ugly hack to skip the title
    assert_equal(csrMatrix.to_s[10...-1], dokMatrix.to_s[10...-1])
  end

end