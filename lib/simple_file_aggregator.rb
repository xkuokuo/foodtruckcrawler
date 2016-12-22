#!/usr/bin/env ruby
require 'pry'
require 'json'

class SimpleFileAggregator
  def initialize(filename)
    @filename = filename
    @mutex = Mutex.new
    if File.exist?(filename)
      File.open(filename, 'w') {|f| f.write('')}
    end
  end

  def aggregate(obj)
    @mutex.synchronize {
      File.open(@filename, 'a') { |f|
        f.write(obj.to_json + "\n")
      }
      
    }
  end
end
