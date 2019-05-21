require_relative 'flicks'
require_relative 'process'
require "test/unit"
include Test::Unit::Assertions

# This is the driver for part2
# This program creates a child process before the parent process is given control of the shell
# The child process will wait the designated amount of time before printing out the message provided
# This exercise makes use of the flicks C++ library and the utilization of the SWIG wrapper

# INPUT: from the command line, provide how many milliseconds the child process will wait before printing
# followed by the message enclosed in parenthesis
# i.e ruby part2_driver.rb 1000 "wait for one second"

# get arguments from the command line. The first argument has to be an integer while the
# second argument can be a string of any characters

# pre conditions: the input must have two arguments where the first is the specified time for the process to wait
# in milliseconds. The second argument is the message that will be printed after the delay.
# The first argument must be a positive integer that is less than or equal to 600000 (10 minutes). The
# second argument is a string
#
# check for valid input
assert(ARGV.length < 3, 'Too many arguments')
assert(ARGV.length > 1, 'Not enough arguments')

assert(ARGV[0].to_i.to_s == ARGV[0], 'Non-Integer for Argument 0')

# The user will enter how long they want to delay in milliseconds
# Provide an upper and lower maximum
# Max wait is 10 minutes, Minimum wait is 0
assert(ARGV[0].to_i < 6000000, 'Max allowable wait time exceeded')
assert(ARGV[0].to_i >= 0, 'Negative wait times not allowed')

# initialize parent process
process = RubyProcess.new(ARGV[0].to_i, ARGV[1])

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC) # start timer

# create the child process
pid = fork do
  # child process
  seconds = ARGV[0].to_i / 1000.0
  required_flicks = Flicks::flicks_per_second * seconds

  while true
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting # return value is in seconds
    elapsed_flicks = Flicks::flicks_per_second * elapsed
    if elapsed_flicks >= required_flicks
      break
    end
  end
  process.print_message
  Process.kill("KILL", Process.pid)
end
Process.detach(pid)

# this is parent process, give shell
process.execute_shell
# if shell terminated then kill child process and exit

begin
  Process.kill("KILL", pid )
  sleep(0.2)
rescue SystemCallError => e
  # error if process was already killed
end

# post conditions: the child process is terminated before exiting
begin
  Process.kill(0, pid)
rescue SystemCallError => e
  exit
end

# if child proces still exists then we have an error
abort('Child Process not terminated properly')

