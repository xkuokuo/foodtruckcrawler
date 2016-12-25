#!/usr/bin/env ruby
require "celluloid"
require 'celluloid/current'

class Me < Celluloid::SupervisionGroup
end

class Cell 
  include Celluloid
  def wakeup
    sleep(2)
    puts "I'm alive!"
    "I'm alive"
  end
end

if __FILE__ == $0
  cell = Cell.new
  cell2 = Cell.new
  cell.async.wakeup
  cell2.async.wakeup
  Cell.run
end
