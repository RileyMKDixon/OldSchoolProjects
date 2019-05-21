require 'contracts'
require 'timeout'
require_relative 'cust_contracts'

module Merge_sort
    include Contracts::Core
    include Contracts::Builtin

    C = Contracts

    #This is the public function that should be called. endPosition is
    #typically the size of the array, however it could be the portion
    #of the array to be sorted up to (not including) this ending position.
    Contract Custom::ComparableArray, C::Num, C::Num => nil
    def self.merge_sort_serial(list, startPosition, endPosition)
        workList = Array.new(list)
        merge_sort_serial_algorithm(workList, startPosition, endPosition-1, list)
    end

    #Swapping between the original array and the working array is a trick
    #to prevent having to copy our results back in place.
    Contract Custom::ComparableArray, C::Num, C::Num, Custom::ComparableArray => nil
    def self.merge_sort_serial_algorithm(workList, startPosition, endPosition, list)
        if (startPosition < endPosition)
            midpointPositon = (startPosition + endPosition)/2
            merge_sort_serial_algorithm(list, startPosition, midpointPositon, workList)
            merge_sort_serial_algorithm(list, midpointPositon+1, endPosition, workList)
            merge_halves(workList, startPosition, midpointPositon, endPosition, list)
        end
        return nil #Force return nil
    end

    #This merges two halves together. Intended for the serial solution
    #However could be adopted for the parallel solution.
    def self.merge_halves(list, startPosition, midpointPositon, endPosition, returnList)
        leftIndex = startPosition
        rightIndex = midpointPositon+1
        newList = Array.new

        for k in 0...(endPosition-startPosition+1)
            if (leftIndex < midpointPositon+1) && 
                (rightIndex > endPosition || (list[leftIndex] <=> list[rightIndex]) < 1)
                returnList[startPosition+k] = list[leftIndex]
                leftIndex += 1
            else
                returnList[startPosition+k] = list[rightIndex]
                rightIndex += 1
            end
        end
        return nil #Force return nil
    end

    def self.find_median_index_reverse(value, arr)
        # This will be for the reverse sort
        # binary search
        index = nil
        startidx = 0
        endidx = arr.length - 1
        while startidx <= endidx
            # get the middle index value
            index = (endidx + startidx) / 2
            if (arr[index] <=> value) == 0
                return index
            elsif (arr[index] <=> value) > 0
                # move startindex to right
                startidx = index + 1
            elsif (arr[index] <=> value) < 0
                # move end index to left
                endidx = index - 1
            end

        end
        if (arr[index] <=> value) < 0
            return index - 1
        end
        return index
    end

    def self.find_median_index(value, arr)
        # binary search
        index = nil
        startidx = 0
        endidx = arr.length - 1
        while startidx <= endidx
            # get the middle index value
            index = (endidx + startidx) / 2
            if (arr[index] <=> value) == 0
                return index
            elsif (arr[index] <=> value) < 0
                # move startindex to right
                startidx = index + 1
            elsif (arr[index] <=> value) > 0
                # move end index to left
                endidx = index - 1
            end

        end
        if (arr[index] <=> value) > 0
            return index - 1
        end
        return index
    end

    def self.p_merge(first, second, reverse)
        # this is the merge function for parallel mergesort
        result = []
        if !first.kind_of?(Array)
            first = [first]
        end

        if !second.kind_of?(Array)
            second = [second]
        end
        # First, make sure the larger array is first, if not then swap
        if second.length > first.length
            result = p_merge(second, first, reverse)
        elsif first.length == 1
            if second.length == 1
                # if the length length of the second array is also one, order them and return
                if (first[0] <=> second[0]) < 0 || (first[0] <=> second[0]) == 0
                    if reverse  # if reverse sort, then we need to flip the logic
                        result = [second[0], first[0]]
                    else
                        result = [first[0], second[0]]
                    end

                else
                    if reverse  # flip logic if sorting in reverse
                        result = [first[0], second[0]]
                    else
                        result = [second[0], first[0]]
                    end
                end
            else
                result = first[0]  # if only the first array has a result
            end
            # now we need to find the index where the median of the first array would be if it was in the
            # second array
        else
            arr1_median = (first.length - 1) / 2

            if reverse
                j = find_median_index_reverse(first[arr1_median], second)

            else
                j = find_median_index(first[arr1_median], second)
            end

            # spawn new threads for p_merge
            firstresult = []
            secondresult = []
            td1 = Thread.new {
                if j < 0
                    # if the median index is below the second array, we merge the upper portion of array one
                    # with the entirety of the second array and append it to the lower portion of the first array
                    firstresult = first[0..arr1_median]
                else
                    firstresult = p_merge(first[0..arr1_median], second[0..j], reverse)
                end

            }
            td2 = Thread.new {
                if j + 1 <= second.length - 1
                    # if J + 1 goes beyond the second array we don't want to split up the second array
                    # Rather we merge the lower portion of the first array with the entirety of the second array
                    # And then finally append the upper portion to that result
                    secondresult = p_merge(first[arr1_median+1..first.length-1], second[j+1..second.length - 1], reverse)
                else
                    secondresult = first[arr1_median+1..first.length-1]
                end

            }

            td1.join
            td2.join

            if !secondresult.kind_of?(Array)  # if there is only one element
                firstresult << secondresult
            elsif
            secondresult.each do |e|
                # add second result to first result
                firstresult << e
            end

            end

            result = firstresult

        end
        return result

    end

    def self.p_sort(arr, reverse = false, startidx = 0, endidx = arr.length - 1)
        # function to sort the items with parallel mergesort
        if startidx == endidx
            return arr[startidx]  # base case where we return one element
        elsif arr.length ==0
            return []  # empty array
        end

        # we need to split into two arrays if not base case
        # first get the median value
        median = (endidx + startidx) / 2
        firststartidx = startidx
        firstendidx = median
        secondstartidx = median + 1
        secondendidx = endidx
        firstarr = arr[firststartidx..firstendidx]
        secondarr = arr[secondstartidx..secondendidx]


        # create threads to split the arrays
        td1 = Thread.new { firstarr = p_sort(firstarr, reverse)}
        td2 = Thread.new {  secondarr = p_sort(secondarr, reverse)}
        td1.join
        td2.join


        result = p_merge(firstarr, secondarr, reverse)
        return result

    end
    
    #provide a parallel solution in addition to our serial solution
    Contract Custom::ComparableArray, C::Pos, C::Bool => C::Or[nil, Custom::ComparableArray]
    def self.merge_sort_parallel(arr, timeout, reverse)
        begin
            start = Time.now
            Timeout::timeout(timeout) do
                result = p_sort(arr, reverse)
                elapsed = Time.now - start
                if !result.kind_of?(Array)
                    result = [result]  # convert to array
                end
                return result
            end
        rescue Timeout::Error
            elapsed = Time.now - start
            puts "Operation Timed Out - Time Elapsed: %0.3f seconds" % [elapsed]
            return nil
        end

    end

    #Outside users should not call any of these functions
    private_class_method :merge_halves, :merge_sort_serial_algorithm, :p_sort, :p_merge, :find_median_index

end