#!/usr/bin/env ruby
require_relative "../lib/foodtruck_crawler"

if __FILE__ == $0
  crawler = FoodtruckCrawler.new
  crawler.start
end
