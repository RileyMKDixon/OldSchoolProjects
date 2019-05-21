require 'test/unit'
require_relative "../lib/merge_sort.rb"

class FileManipulationTests < Test::Unit::TestCase

    def setup()
        @randGen = Random.new
        
    end

    def teardown()

    end

    def test_int_sort()
        testArray = Array.new
        200.times{testArray.push(@randGen.rand(-100..100))}

        confirmSortedArray = testArray.sort
        Merge_sort.merge_sort_serial(testArray, 0, testArray.length)

        assert_true(confirmSortedArray.eql?testArray)
    end

    def test_char_sort()
        testArray = Array.new
        200.times{testArray.push(@randGen.rand(65..90).chr)}

        confirmSortedArray = testArray.sort
        Merge_sort.merge_sort_serial(testArray, 0, testArray.length)

        assert_true(confirmSortedArray.eql?testArray)
    end

    def test_string_sort()
        testArray = Array.new
        200.times{testArray.push(('a'..'z').to_a.shuffle[0,8].join)}

        confirmSortedArray = testArray.sort
        Merge_sort.merge_sort_serial(testArray, 0, testArray.length)

        assert_true(confirmSortedArray.eql?testArray)
    end

    def test_int_sort_parallel()
        testArray = Array.new
        200.times{testArray.push(@randGen.rand(-100..100))}

        confirmSortedArray = testArray.sort
        testArrayReturned = Merge_sort.merge_sort_parallel(testArray, 10, false)

        assert_true(confirmSortedArray.eql?testArrayReturned)
    end

    def test_char_sort_parallel()
        testArray = Array.new
        200.times{testArray.push(@randGen.rand(65..90).chr)}

        confirmSortedArray = testArray.sort
        testArrayReturned = Merge_sort.merge_sort_parallel(testArray, 10, false)

        assert_true(confirmSortedArray.eql?testArrayReturned)
    end

    def test_string_sort_parallel()
        testArray = Array.new
        200.times{testArray.push(('a'..'z').to_a.shuffle[0,8].join)}

        confirmSortedArray = testArray.sort
        testArrayReturned = Merge_sort.merge_sort_parallel(testArray, 10, false)

        assert_true(confirmSortedArray.eql?testArrayReturned)
    end

    def test_ints_and_float_parallel()
        intArray = Array.new
        100.times{intArray.push(@randGen.rand(-100..100))}
        floatArray = Array.new
        100.times{floatArray.push(@randGen.rand(-100.0..100.0))}

        intArray.concat(floatArray)

        confirmSortedArray = intArray.sort
        testArrayReturned = Merge_sort.merge_sort_parallel(intArray, 10, false)

        assert_true(confirmSortedArray.eql?testArrayReturned)
    end


end