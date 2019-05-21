require_relative "../lib/board.rb"
require_relative "../lib/token.rb"


workingBoard = Board.new
# workingBoard.try_place_token(1, Token.new("O"))
while(true)
    puts workingBoard
    puts "Please enter what column to put a token in: "
    selection = (gets.chomp.to_i)
    if(selection == -1)
        break
    end
    newToken = Token.new("X")
    rowPlaced = workingBoard.try_place_token(selection, newToken)
    if(rowPlaced == -1)
        puts "COLUMN FILLED"
    else
        workingBoard.get_neighbours(rowPlaced, selection, 2)
    end
end

# answer = workingBoard.get_element_value(0, 0)
# if(answer.nil?)
#     puts "Nil"
# else
#     puts workingBoard.get_element_value(0, 0)
# end

# puts workingBoard.get_element_value(0, 1)
# puts workingBoard.get_element_value(0, 2)

#newArray = [[1,2,3,4,5,6,7],["A","B","C","D","E","F","G"],["H","I","J","K","L","M","N"],["O","P","Q","R","S","T","U"],["V","W","X","Y","Z",".",","],["/","?",":",";","<",">","|"]]
#workingBoard.data = newArray
puts workingBoard
#workingBoard.get_neighbours(3,4,2) #Does not work with primitives unless Board::get_element_value is modified



