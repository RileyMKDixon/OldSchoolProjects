require 'etc'
require 'thwait'

class SortThread

  attr_accessor :array, :cores

  def initialize(array)
    @array = array
    @cores = Etc.nprocessors
  end

  def finalmerge(arr1, arr2)
    result = Array.new(arr1.length, arr2.length)
    i, j, r = 0, 0, 0
    while i < arr1.length and j < arr2.length
      if arr1[i] <= arr2[j]
        result[r] = arr1[i]
        i += 1
        r += 1
      else
        result[r] = arr2[j]
        j += 1
        r += 1
      end

      if i==arr1.length
        while j < arr2.length
          result[r] = arr2[j]
          r += 1
          j += 1
        end
      end

      if j == arr2.length
        while i < arr1.length
          result[r] = arr1[i]
          r += 1
          i += 1
        end
      end
    end
    result
  end

  def breakdown
    # breaks down array into n distinct arrays
    collection, threads = [], []
    breaks = @array.length/@cores
    for i in 0...@cores
      first = i * breaks
      last = first + breaks
      split = @array[first...last]
      if i == @cores - 1
        split = @array[first..-1]
      end
      threads << Thread.new { sort(split) }
      collection.append(split)
    end

    ThreadsWait.all_waits(*threads)

    threaddedMergeFinal(collection)
  end

  def threaddedMergeFinal(arr)
    collection = []
    thr = []
    if arr.length == 1
      return arr[0]
    end
    for x in (0...arr.length).step(2)
      # extrmeley buggy, there is a race condition here
      # p "ITERATION", x, arr[x], arr[x + 1]
      arr1 = arr[x]
      arr2 = arr[x + 1]
      thr << Thread.new {Thread.current[:output] = finalmerge(arr1, arr2)}
    end
    thr.each do |t|
      t.join
      collection << t[:output]
    end
    threaddedMergeFinal(collection)
  end

  def mergeSort(arr, left, right)
    if left < right
      middle = (left + right)/2
      # Left is now sorted, right is now sorted
      mergeSort(arr, left, middle)
      mergeSort(arr, middle + 1, right)


      merge(arr, left, middle, right)

    end
  end


  def merge(arr, left, middle, right)
    upper = middle + 1
    if arr[middle] <= arr[upper]
      return
    end

    while (left <= middle and upper <= right)

      if (arr[left] <= arr[upper])
        left += 1
      else
        v = arr[upper]
        index = upper

        while (index != left)
          arr[index] = arr[index - 1]
          index -= 1
        end

        arr[left] = v

        left += 1
        middle += 1
        upper += 1
      end
    end
  end

  def sort(arr)
    mergeSort(arr, 0, arr.length - 1)
  end
end

generated_numbers = 1000.times.map{Random.rand(10000)} #=> [4, 2, 6, 8]

srt = SortThread.new(generated_numbers)

t1 = Time.now
srt.breakdown
t2 = Time.now

generated_numbers2 = 1000.times.map{Random.rand(10000)} #=> [4, 2, 6, 8]

puts "PARALLEL", t2-t1

array = srt.array

t1 = Time.now
srt.sort(array)
t2 = Time.now


puts "SEQUENTIAL", t2-t1


