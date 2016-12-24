#!/usr/bin/env ruby
require 'pry'
require 'json'

class SimpleFileAggregator
  def initialize(filename)
    @filename = filename
    @has_crawled = {}
    @count = 0;
    @mutex = Mutex.new
    if File.exist?(filename)
      File.open(filename, 'w') {|f| f.write('')}
    end
  end

  def aggregate(obj)
    @count += 1
    if !obj.present? 
      return
    end
    @has_crawled[obj[:url]] = true
    @mutex.synchronize {
      File.open(@filename, 'a') { |f|
        f.write(obj.to_json + "\n")
      }
    }
  end

  def has_crawled(url)
    @has_crawled[url]
  end

  def count
    return @count
  end
end
