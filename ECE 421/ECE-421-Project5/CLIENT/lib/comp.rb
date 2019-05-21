class Comp

  def initialize board, row, col, ai, player, difficulty

    @board = board
    @row = row
    @col = col

    # value between 0 and 1, 1 = most difficult, 0 = least difficult
    @difficulty = difficulty

    @ai = ai
    @player = player
  end


  # if we place a token at this position, does the player get a win condition?
  def evaluate_position_as player, row, col, win_condition, score

    result = 0

    # score of 0, we cant place it there
    if row >= @row
      return result
    end

    @board.data[row][col] = player.generate_token

    @board.get_neighbours(row, col, win_condition.length).each do |neighbours|

      if check_if_neighbour_win neighbours, win_condition
        result = score
        break
      end
    end

    # function does not reset the board
    return result

  end

  # check if have any 3 rows, returns 1 if win, 0 if not win, -1 if tied
  def make_move


    candidates = []
    surface_level.each do |pos|

      row, col = pos

      # if placing this tile leads the ai to win then thats good
      score = evaluate_position_as @ai, row, col, @ai.win_conditions[0], 2

      # if placing tile, enables the player to place a tile above us and win, then bad
      score += evaluate_position_as @player, row + 1, col, @player.win_conditions[0], -1
      @board.data[row][col] = nil

      if row + 1 != @row
        @board.data[row + 1][col] = nil
      end

      # if player places this position and enables him to win, dont let him.
      score += evaluate_position_as @player, row, col, @player.win_conditions[0], 0.8
      @board.data[row][col] = nil


      # if ai places at this tile and causes player to win, dont palce it there
      score += evaluate_position_as @ai, row, col, @player.win_conditions[0], -2

      # if player plays it there and causes him to get close to win conditon, dont palce it there
      score += evaluate_position_as @player, row, col, @player.win_conditions[0][1..-1], 0.3
      @board.data[row][col] = nil


      score += evaluate_position_as @player, row, col, @player.win_conditions[0][0..-2], 0.3
      @board.data[row][col] = nil

      candidates << [row, col, score]

    end

    # signals that it cannot make a move, the ai
    if candidates == []
      return -1
    end

    # sort by best candidate
    sorted = candidates.sort {|a,b| b[2] <=> a[2]}

    return select_candidate sorted

  end

  def select_candidate sorted_candidates

    # worst choice possible
    candidate = sorted_candidates[-1][1]
    sorted_candidates.each do |c|
      if rand(0.0..1.0) <= @difficulty
        candidate = c[1]
        break
      end
    end
    candidate
  end

  # look at the neighbours, is there a win condition?
  def check_if_neighbour_win neighbours, pattern
    # p pattern
    result = ""
    for token in neighbours
      result += token.to_s
    end
    return Regexp.new(pattern).match result
  end

  # gets the "surface" of the board, ie all positions in which it is available to place
  def surface_level
    result = []
    for col in 0...@col
      for row in 0...@row
        if@board.data[row][col] == nil
          result << [row , col]
          break
        end
      end
    end

    return result
  end


end
