require "test/unit"
include Test::Unit::Assertions
require_relative 'board_view.rb'


class Board

    #DEBUG ACCESSOR, PLEASE REMOVE FOR RELEASE
    attr_accessor :data

    def initialize(rows = 6, cols = 7)
        @rows = rows
        @cols = cols
        @data = Array.new(@rows) { Array.new(@cols, nil) }
        @board_view = nil
        @spaces = rows * cols
        @spaces_filled = 0

    end

    def make_view()
        @board_view = BoardWindow.new(@rows, @cols, "../ui/game_grid.glade", "../ui/token_place.png")
        return @board_view
    end

    def set_info(info)
        @board_view.set_info(info)
    end

    def try_place_token(col, token)
        # Return -1 if can't place or something
        # Return row
        assert(col < @cols, "Trying to place a token after the board ends.")
        assert(col >= 0, "Trying to place a token before the board begins.")
        assert(token.is_a?(Token), "The token passed is not a token.")

        result = -1  # change later

        @data.each_index{ |rowIndex|
            if(@data[rowIndex][col].nil?)
                @data[rowIndex][col] = token
                result = rowIndex
                if !@board_view.nil?
                    @board_view.update(rowIndex, col, token)
                    # increment space counter
                    @spaces_filled += 1
                end
                # update board
                break
            end
        }

        # must return either -1 or a row value
        assert(result.is_a?(Integer))
        return result
    end

    def get_neighbours(row, col, radius)
        # Return 4 arrays representing each cardinal direction
        # of length radius around (row, col)
        # If radius is set to 0, equal to calling get_element_value
        assert(col < @cols, "Requested column is after the board ended.")
        assert(col >= 0, "Requested column is before the board begins.")
        assert(row < @rows, "Requested row is after the board ended.")
        assert(row >= 0, "Requested row is before the board begins.")
        assert(radius >= 0, "Radius must be a positive integer.")

        result = []
        # Use get_element_value to populate arrays
        horizontalNeighbours = get_horizontal_neighbours(row, col, radius)
        result.push(horizontalNeighbours)
        # puts "HN: " + horizontalNeighbours.to_s
        verticalNeighbours = get_vertical_neighbours(row, col, radius)
        result.push(verticalNeighbours)
        # puts "VN: " + verticalNeighbours.to_s
        backwardsDiagonalNeighbours = get_backwards_diagonal_neighbours(row, col, radius)
        result.push(backwardsDiagonalNeighbours)
        # puts "BN: " + backwardsDiagonalNeighbours.to_s
        forwardsDiagonalNeighbours = get_forwards_diagonal_neighbours(row, col, radius)
        result.push(forwardsDiagonalNeighbours)
        # puts "FN: " + forwardsDiagonalNeighbours.to_s

        result.push(horizontalNeighbours).push(verticalNeighbours).push(backwardsDiagonalNeighbours).push(forwardsDiagonalNeighbours)
        # return an array of strings for the four directions
        assert(result.is_a?(Array), "Output is not an Array.")
        return result
    end


    def to_s
        returnString = ""
        @data.reverse_each { |row|
            row.each{ |element|
                #Reverse as we are printing top down
                if(element.nil?)
                    returnString << "."
                else
                    returnString << element.to_s
                end
            }
            returnString << "\n"
        }
        return returnString
    end

    def board_filled?
        return @spaces == @spaces_filled
    end

    private # Everything after here is private

    def get_element_owner(row, col)
        #Since this is a private method I think we can go without the
        #assert statements as only this class internally should use them.
        #They permit out of bounds values as it is guarunteed to return nil
        #Which is desired.

        #assert(col < @cols, "Requested column is after the board ended.")
        #assert(col >= 0, "Requested column is before the board begins.")
        #assert(row < @rows, "Requested row is after the board ended.")
        #assert(row >= 0, "Requested row is before the board begins.")
        if(0 > col || col >= @cols || 0 > row || row >= @rows)
            return nil
        end

        requestedElement = @data[row][col]
        if(requestedElement.nil?)
            return nil
        else
            #return requestedElement #Used for simple debugging without Tokens
            return requestedElement.owner
        end
    end

    #Gets the neighbouring elements from the same row
    def get_horizontal_neighbours(row, col, radius)
        startPosition = [0, col-radius].max
        endPosition = [@cols, col+radius].min

        horizontalNeighbours = []
        @data[row][startPosition..endPosition].each{|curCol|
            if(curCol.nil?)
                horizontalNeighbours.push(nil)
            else
                horizontalNeighbours.push(curCol.owner)
            end
        }

        return horizontalNeighbours
    end

    #Get the neighbouring elements form the same column
    def get_vertical_neighbours(row, col, radius)
        startPosition = [0, row-radius].max
        endPosition = [@rows, row+radius].min

        verticalNeighbours = []
        @data[startPosition..endPosition].each{|curRow|
            if(curRow[col].nil?)
                verticalNeighbours.push(nil)
            else
                verticalNeighbours.push(curRow[col].owner)
            end
        }

        return verticalNeighbours
    end

    #Get the neighbouring elements in the backwards diagonal
    def get_backwards_diagonal_neighbours(row, col, radius)
        rowPositions = (row-radius..row+radius).to_a.reverse
        colPositions = (col-radius..col+radius).to_a

        #RowPositions and ColPositions have the same number of elements
        #Either could be used here, I just chose to use rows.
        #The positions of each row and column however do have a 1-1 correspondance
        backwardsDiagonalNeighbours = []

        rowPositions.each_index{ |index|
            backwardsDiagonalNeighbours.push(get_element_owner(rowPositions[index], colPositions[index]))
        }
        #removes any nil elements
        # return backwardsDiagonalNeighbours.compact
        return backwardsDiagonalNeighbours  # keep nils for now
    end

    #Get the neighbouring elements in the forwards diagonal
    def get_forwards_diagonal_neighbours(row, col, radius)
        rowPositions = (row-radius..row+radius).to_a
        colPositions = (col-radius..col+radius).to_a

        #RowPositions and ColPositions have the same number of elements
        #Either could be used here, I just chose to use rows.
        #The positions of each row and column however do have a 1-1 correspondance
        forwardsDiagonalNeighbours = []

        rowPositions.each_index{ |index|
            forwardsDiagonalNeighbours.push(get_element_owner(rowPositions[index], colPositions[index]))
        }
        #removes any nil elements
        #return forwardsDiagonalNeighbours.compact
        return forwardsDiagonalNeighbours  # keep nils for now
    end
    

end
