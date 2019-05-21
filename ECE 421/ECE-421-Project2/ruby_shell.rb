require 'shellwords'
require_relative 'monitor_driver'

module RubyShell

  # main loop
  def self.interface
    exitShell = false
    while !exitShell
      begin
        print "RubyShell:"+Dir.pwd+"$"
        exitShell = get_command
      rescue StandardError => e
        puts e
        break
      end
    end
  end

  # Gets the command from user
  def self.get_command
    line = gets.strip
    if line.length > 1000
      puts 'Exceeded input limit (1000)'
    end
    input = Shellwords.shellsplit(line)
    if input == []
      return false
    end
    if input[0] == "ls"
      path = input.length > 1 ? input[1...input.length].shelljoin : '.'
      list_directory path
    elsif input[0] == "cd"
      change_directory input[1...input.length].shelljoin
    elsif input[0] == "kill"
      kill_process(input[1])
    elsif input[0] == "mkdir"
      make_directory input[1...input.length]
    elsif input[0] == "rmdir"
      remove_directory input[1...input.length]
    elsif input[0] == "mkfile"
      make_file input[1...input.length]
    elsif input[0] == "rmfile"
      remove_file input [1...input.length]
    elsif input[0] == "exit"
      return true
    else
      execute_process input
      #execute_process input
    end
    return false
  end

  # Lists directory
  def self.list_directory(path)
    begin
      puts(Dir.entries(path).reject{|n| n[0] == '.'})
    rescue SystemCallError => e
      puts e
    end
  end

  # Changes current directory
  def self.change_directory(path)
    # the path needs to be sanitized, cant be something that is hostile?
    begin
      Dir.chdir path
    rescue SystemCallError => e
      puts e
    end
  end

  def self.kill_process(pid)
    # if integer
    if pid.match(/^(\d)+$/)
      pid = Integer(pid)
    end
    begin
      Process.kill('QUIT', pid)
    rescue SystemCallError => e
      puts e
    end
  end

  #Create a directory in current
  def self.make_directory(arguments)
    #Assert that arguements is type List && 
    #all entries in arguments are type String

    #puts arguments

    if(arguments.length == 0)
      puts "No directory name given."
      return
    end

    setPermissionsFlag = false
    permissionsValue = 0
    directoryNames = []
    
    begin
      if(arguments[0] == "-p")
        permissionsValueStr = arguments[1]
        if !permissionsValueStr.match(/[0-7]{3}/) || permissionsValueStr.length != 3
          raise ArgumentError, "Invalid Permissions Specified"
        end
        permissionsValue = permissionsValueStr[0].ord * 100 + 
                           permissionsValueStr[1].ord * 10 + 
                           permissionsValueStr[2].ord
        arguments.delete_at(0) #remove optional parameter
        arguments.delete_at(0) #remove optional parameter value
      elsif(arguments[0] == "-h")
        puts "Make a directory in the current directory. Use -p " +
             "to set permissions for the directory."
        arguments.delete_at(0) #remove -h
      elsif(arguments[0][0] == '-' && (arguments[0][1] != 'p'|| arguemnts[0][1] != 'h'))
        raise ArgumentError, "Unknown Argument Provided"
      end

      for dirName in arguments
        dirName = dirName.strip

        if dirName == "" ||
           dirName.match(/[\/[[:cntrl:]]]/) ||
           dirName == "." ||
           dirName == ".."
           raise ArgumentError, "Directory name #{dirName} is not valid"
        end

        if(setPermissionsFlag == true)
          Dir.mkdir(dirName, permissionsValue)
        else
          Dir.mkdir(dirName)
        end
      end
    rescue SystemCallError => e
      puts "Failed to create directory."
      puts e
    rescue ArgumentError => ve
      puts ve
    end

  end

  def self.remove_directory(arguments)
    begin
      if(arguments[0] == "-h")
        puts "Deletes the specified directories specified in " +
        "the current directory. Directory must be empty."

        arguments.delete_at(0) #remove optional parameter
      elsif(arguments[0][0] == '-' && arguments[0][1] != 'h')
        raise ArgumentError, "Unknown Argument Provided"
      end

      for dirName in arguments
        dirName = dirName.strip
        Dir.delete(dirName)
      end

    rescue SystemCallError => sce
      puts "Failed to remove directory."
      puts sce
    rescue ArgumentError => ve
      puts ve
    end
  end

  def self.make_file(arguments)
    begin
      setPermissionsFlag = false
      permissionsValue = 0
      directoryNames = []

      if(arguments[0] == "-p")
        permissionsValueStr = arguments[1]
        if !permissionsValueStr.match(/[0-7]{3}/) || permissionsValueStr.length != 3
          raise ArgumentError, "Invalid Permissions Specified"
        end
        permissionsValue = permissionsValueStr[0].ord * 100 + 
                           permissionsValueStr[1].ord * 10 + 
                           permissionsValueStr[2].ord
        arguments.delete_at(0) #remove optional parameter
        arguments.delete_at(0) #remove optional parameter value
      elsif(arguments[0] == "-h")
        puts "Make a file in the current directoy. Use -p " +
             "to set permissions for the file.\n" +
             "First argument is file name and extension followed " + 
             "by text to be put into the file."
        arguments.delete_at(0) #remove -h
      elsif(arguments[0][0] == '-' && (arguments[0][1] != 'p' || arguments[0][1] != 'h'))
        raise ArgumentError, "Unknown Argument Provided"
      end

      if(arguments.length >= 1)
        fileName = arguments[0]
        for word in arguments[1...arguments.length]
          fileText += word + " "
        end

        newFile = File.new(fileName, "w+")
        if(setPermissionsFlag == true)
          newFile.chmod(permissionsValue)
        end
        newFile.syswrite(fileText)
      else
        raise ArgumentError, "Not enough parameters passed."
      end

    rescue SystemCallError => e
      puts "Failed to create file."
      puts e
    rescue ArgumentError => ve
      puts ve
    end
  end

  def self.remove_file(arguments)
    begin
      if(arguments[0] == "-h")
        puts "Deletes the specified files specified in " +
        "the current directory."

        arguments.delete_at(0) #remove optional parameter
      elsif(arguments[0][0] == '-' && arguments[0][1] != 'h')
        raise ArgumentError, "Unknown Argument Provided"
      end

      for fileName in arguments
        fileName = fileName.strip
        File.delete(fileName)
      end

    rescue SystemCallError => sce
      puts "Failed to remove file."
      puts sce
    rescue ArgumentError => ve
      puts ve
    end
  end

  # executes a process
  def self.execute_process(command)
    pid = Process.fork do
      begin
        exec(*command)
      rescue SystemCallError => e
        puts e
      end
    end
    Process.wait(pid)
  end
end
