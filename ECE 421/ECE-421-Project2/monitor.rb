module MonitorFile

  def self.FileWatch(type, duration, file_list)

    # PRE CONDITION
    action = false
    file_status = {}
    file_list.each do |n|
      file_status[n] = File.exist?(n) ? [1, File.ctime(n)] : [-1, -1]
    end

    Thread.new do

      while true
        file_list.each do |n|

          if type.index('c') && file_status[n][0] == -1 && File.exist?(n)
            file_status[n][0] = 1
            action = true
          end

          if type.index('a') && File.exist?(n) && file_status[n][1] != File.ctime(n)
            file_status[n][1] = File.ctime(n)
            action = true
          end

          if type.index('d') && !File.exist?(n) && file_status[n][0] == 1
            file_status[n][0] = -1
            action = true
          end
        end

        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        while (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) < (duration * 0.001)
        end

        if action
          begin
            yield
            action = false
          rescue SystemCallError => e
            puts e
          end
        end
      end
    end
  end

end