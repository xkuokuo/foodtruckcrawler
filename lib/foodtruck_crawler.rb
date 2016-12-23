require 'json'
require_relative 'webdriver_proxy'
require_relative 'task_manager'
require_relative 'simple_file_aggregator'

class FoodtruckCrawler 
  def start
    puts "Let's Start!"
    url = "http://www.seattlefoodtruck.com"
    filename = "../aggregator_result.txt"
    filename = File.join(File.dirname(__FILE__), filename)
    driver = WebdriverProxy.new :chrome
    templates = []
    templates = [JSON.parse(readfile("../template/foodtruckhome.json")), JSON.parse(readfile("../template/foodtruck.json"))]
    task_manager = TaskManager.new(webdriver: driver, urls: url, templates: templates, aggregator: SimpleFileAggregator.new(filename))
    task_manager.start
    driver.close
    puts "Crawling finished. Result stored in " + filename
  end
end

def readfile(filename)
  res_str = ""
  File.open(File.join(File.dirname(__FILE__), filename)) { |f|
    f.each_line { |line|
      res_str = res_str + line
    }
  }
  res_str
end

