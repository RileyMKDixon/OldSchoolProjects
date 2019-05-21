require 'sqlite3'

class DBCommands

  def initialize

    @dbconn = SQLite3::Database.open 'data'
    
  end

  # Performs a login
  def verifyUser username, password


      stm = @dbconn.prepare 'SELECT * FROM players WHERE uname=? AND password=?;'
      rs = stm.execute! username, password

      # if we found a result
      if rs.length == 0
        return false
      end

      return true

    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
      return false
  end

  # Registers a user
  def registerUser username, password

    begin

      # verify if the username like username exisrs
      stm = @dbconn.prepare 'SELECT * FROM players WHERE uname=?;'
      rs = stm.execute! username

      # if we found a result, user cannot register
      if rs.length > 0
        return false
      end

      # register user with new name and password
      @dbconn.execute 'INSERT INTO players VALUES(?, ?);', [username, password]
      return true

    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
      return false
    end
  end

  # creates a new game
  def createNewGame row, col, p1token, p2token, p1pat, p2pat, p1id

    begin

      # obtain the max gameid for now
      stm = @dbconn.prepare 'SELECT MAX(gameid) FROM games;'
      rs = stm.execute!

      gameid = rs[0][0] == nil ? 0 : rs[0][0] + 1

      # NOTE that for gameid, -1 indicates game not started yet, 0
      # indicates game in progress, 1 indicates game finished
      @dbconn.execute('INSERT INTO games VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?);',
                      [gameid, row, col, p1token, p2token, p1pat, p2pat, p1id, '!', -1])

      return true

    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
      return false
    end

  end

  # inserts a move
  def insertMove gameid, playerid, col

    begin

      stm = @dbconn.prepare 'SELECT MAX(n), playerid FROM moves WHERE gid=?;'
      rs = stm.execute! gameid

      # ensure that the current move, and previous move, is not made by the same player
      if rs[0][0]!= nil and rs[0][1] == playerid
        return false
      end

      # insert move
      @dbconn.execute('INSERT INTO moves VALUES(?, ?, ?, ?);',
                      [gameid, playerid, rs[0][0].to_i + 1, col])

      return true

    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
      return false
    end
  end

end

dbc = DBCommands.new
#
#puts dbc.registerUser 'shang', '1234'
#puts dbc.verifyUser 'shang', '1234'

#puts dbc.createNewGame 7, 8, 'R', 'Y', 'RRRR', 'YYYY', 'shang'
puts dbc.insertMove 0, 'shang', 3