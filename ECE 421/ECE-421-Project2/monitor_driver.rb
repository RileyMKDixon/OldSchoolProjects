require_relative 'monitor'

MonitorFile.FileWatch('cd', 100, ['t.txt']) { puts 'Modified!!!' }
