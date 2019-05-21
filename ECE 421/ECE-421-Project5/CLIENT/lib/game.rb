require "test/unit"
include Test::Unit::Assertions

require "singleton"
require_relative 'board.rb'
require_relative 'player.rb'
require_relative 'comp.rb'

class Game
    include Singleton
    attr_reader :game_over  # if game is over then we do not populate the board anymore

    def initialize()
    end

    def setup(player_count, pieces, win_conditions, colors, rows, cols)
        assert(player_count >= 1)

        win_conditions.each do |cond|
            assert(cond.is_a?(String))
        end

        @players = player_count

        @win_radius = (win_conditions.max_by { |item| item.length }).length - 1

        @board = Board.new(rows, cols)
        @colors = colors
        @player1 = Player.new(pieces[0], colors[0], [win_conditions[0]])
        @game_over = false
        @tied = false

        @player2 = Player.new(pieces[1], colors[1], [win_conditions[1]])
        @hai = Comp.new(@board, rows, cols, @player2, @player1, 0.2)

        @active_player = @player1
    end

    def make_board
        brd = @board.make_view()
        set_info(@active_player.title + "'s turn...")
        return brd
    end

    def set_info(info)
        @board.set_info(info)
    end

    def check_winner(row, col, player1, player2)
        assert(row >= 0)
        assert(row >= 0)


        result = []  # change later

        # check to see if board is filled
        if @board.board_filled?
            @tied = true
            return [player1, player2]  # tis a draw
        end

        # get neighbours
        neighbours = @board.get_neighbours(row, col, @win_radius)
        h_neighbours = neighbours[0]
        v_neighbours = neighbours[1]
        bd_neighbours = neighbours[2]
        fd_neighbours = neighbours[3]

        h_neighbours.each_with_index do |value, index|
            if value.nil?
                # replace any nils with a literal string "nil"
                h_neighbours[index] = "nil"
            end
        end
        
        v_neighbours.each_with_index do |value, index|
            if value.nil?
                # replace any nils with a literal string "nil"
                v_neighbours[index] = "nil"
            end
        end

        fd_neighbours.each_with_index do |value, index|
            if value.nil?
                # replace any nils with a literal string "nil"
                fd_neighbours[index] = "nil"
            end
        end

        bd_neighbours.each_with_index do |value, index|
            if value.nil?
                # replace any nils with a literal string "nil"
                bd_neighbours[index] = "nil"
            end
        end

        h_neighbour_string = h_neighbours.join('')  # these are strings that will be matched with regex
        v_neighbour_string = v_neighbours.join('')
        bd_neighbour_string = bd_neighbours.join('')
        fd_neighbour_string = fd_neighbours.join('')

        # if any of the string above match any of the win_conditions then the player has won
        player1.win_conditions.each do |win_pattern|
            if !h_neighbour_string.match(win_pattern).nil?
                result.push(player1)
            elsif !v_neighbour_string.match(win_pattern).nil?
                result.push(player1)
            elsif !bd_neighbour_string.match(win_pattern).nil?
                result.push(player1)
            elsif !fd_neighbour_string.match(win_pattern).nil?
                result.push(player1)
            end
        end

        player2.win_conditions.each do |win_pattern|
            if !h_neighbour_string.match(win_pattern).nil?
                result.push(player2)
            elsif !v_neighbour_string.match(win_pattern).nil?
                result.push(player2)
            elsif !bd_neighbour_string.match(win_pattern).nil?
                result.push(player2)
            elsif !fd_neighbour_string.match(win_pattern).nil?
                result.push(player2)
            end
        end

        # return players where at least one pattern was matched else result is empty
        return result
    end

    def add_token(col)
        # call try_to_add_token
        # generate token
        token = @active_player.generate_token()
        success = @board.try_place_token(col, token)
        
        # For some reason even if success was -1 this was entering if
        if success != -1
            # check for game ending conditions
            winners = self.check_winner(success, col, @player1, @player2)

            if winners.length > 0

                if winners.length == 1
                    print winners[0].title + " wins!"
                    # end the game here
                    @game_over = true
                    set_info(winners[0].title + " wins!")

                elsif winners.length > 1
                    print "Tied!"
                    @tied = true
                    @game_over = true
                    set_info("It's a tie!")
                end
                return
            end


            @active_player = @active_player == @player1 ? @player2 : @player1
            set_info(@active_player.title + "'s turn...")
            if @players == 1 && @active_player == @player2
                sleep(1) # Give the player time to see the move
                col = @hai.make_move
                # puts col, "COL\n"
                if col >= 0
                    add_token(col)
                else
                    @game_over = true
                end
            end
        end

    end

end
