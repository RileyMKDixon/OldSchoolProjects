require 'socket'
require 'sqlite'
require_relative 'db_commands'

PORT = 8008

Clients = Hash.new
ClientIds = Hash.new

class Server

  def initialize
    @instance = TCPServer.open PORT

    @connections = 0

    # accept connections on some random thread
    @connThread = Thread.new { accept_connections }
    while true

    end
  end

  # communicaiton shared between a specifc client and server
  def communicate client_server_id

    # every communication channel will have its own connection to the database?
    client = Clients[client_server_id]
    client_actual_id = ""
    db = DBCommands.new

    while message = client.gets

      # every message has the following structure
      # PURPOSE - body, PURPOSE = segment[0]
      segments = message.split ' '
      purpose = segments[0]
      index = segments[1]
      body = segments[2..]

      if purpose == 'login'
        client_actual_id = _respond_to_login purpose, index, body, db, client

      elsif purpose == 'register'
        client_actual_id = _respond_to_register purpose, index, body, db, client

      elsif purpose == 'loadGame'



      end

    end

  end

  # keeps on accepting connections
  def accept_connections

    while true

      # blocking
      client = @instance.accept


      client.puts 'accepted'

      # either AVAILABLE or TAKEN
      Clients["client" + @connections.to_s] = client

      @connections += 1
    end
  end



  #---------------------------- PRIVATE STUFF ---------------------------
  # Responds to a clients login request
  def _respond_to_login purpose, index, body, db, client

    username = body[0]
    password = body[1]

    if db.verifyUser username, password

      # client increments the index
      client.puts '%s %s %d' % [purpose, index, 200]

      return username
    end

    client.puts '%s %s %d' % [purpose, index, -1]
    return ''
  end



  # Responds to a clients registration request
  def _respond_to_register purpose, index, body, db, client

    username = body[0]
    password = body[1]

    if db.registerUser username, password

      client.puts '%s %s %d' % [purpose, index, 200]

      return username
    end

    client.puts '%s %s %d' % [purpose, index, -1]
    return ''
  end



  # Responds to a clients game request
  def _respond_to_game_creation purpose, index, body, db, client, client_actual_id

    row = body[0]
    col = body[1]
    p1token = body[2]
    p2token = body[3]
    p1pat = body[4]
    p2pat = body[5]

    gameid = db.createNewGame row, col, p1token, p2token, p1pat, p2pat, client_actual_id

    client.puts '%s %s %s' % [purpose, index, gameid]
  end


  # Responds to a clients desire to join a game
  def _respond_to_game_participation purpose, index, body, db, client, client_actual_id

    # TODO implement joingame

  end
end

# for each game instance, client gets the highest number


serv = Server.new