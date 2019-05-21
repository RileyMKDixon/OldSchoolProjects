require_relative 'ruby_shell'

class RubyProcess
  include RubyShell
  attr_accessor :milliseconds, :pid, :message

  # this class will contain the necessary timing information for part 2
  @milliseconds = 0
  @message = ''

  def initialize(milliseconds, message)
    @milliseconds = milliseconds
    @message = message
  end

  def print_message
    # print out the message that was specified to the shell
    puts "\n"
    puts @message
    print "RubyShell:"+Dir.pwd+"$"
  end

  def execute_shell
    # execute the shell
    RubyShell.interface
  end


end
