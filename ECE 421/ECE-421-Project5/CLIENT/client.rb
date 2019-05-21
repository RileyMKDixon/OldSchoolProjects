require 'socket'

response = Hash.new

class Client

  def initialize hostname, port

    @server_conn = TCPSocket.open hostname, port
    @client_id = ""

    while line = @server_conn.gets
      puts line.chomp
    end

  end

  def request_login username, password

    message = 'login - %s %s' % [username, password]

    @server_conn.puts message

    # wait for the servers response (will stall the program)
    response = @server_conn.gets
  end

  def request_new_game

  end

  def request_join_game

  end


  def switch message



  end



end

cli = Client.new 'localhost', 8008