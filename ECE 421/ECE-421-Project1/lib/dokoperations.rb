require 'test/unit/assertions'

module Dokoperations

    def get_element(row, col)
        # pre conditions

        assert(row <= rows, "Row index out of range")
        assert(col <= cols, "Column index out of range")
        item = dict[[row, col]]
        return item
        # post condition
        # element at (row, col)
    end
end