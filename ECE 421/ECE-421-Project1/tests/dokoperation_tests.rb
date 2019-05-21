require 'test/unit'
require_relative '../lib/dokfactory'
require_relative '../lib/factoryproducer'

class DokOperationTests < Test::Unit::TestCase


    def setup
      @test_scalar_matrix = Factoryproducer.get_factory('dok').dok_from_2d_array([[2, 2], [2, 2]])
  
      @result_scalar_matrix = Factoryproducer.get_factory('dok').dok_from_2d_array([[4, 4], [4, 4]])
    end

    def test_dok_from_csr
      matrixValues = Matrix[[1, 0, 3, 6], [1, 5, 3, 12], [7, 0, 9, -6]]
      csrMatrix = Factoryproducer.get_factory('csr').csr_from_matrix(matrixValues)
      dokMatrix = Factoryproducer.get_factory('dok').dok_from_csr(csrMatrix)
      
      #puts csrMatrix.to_s[10...-1] <-Ugly hack to skip the title
      assert_true(csrMatrix.to_s[10...-1] == dokMatrix.to_s[10...-1])
    end

end