require 'json'
require 'pry'
require 'webdriver_proxy'
require 'task_manager'

RSpec.describe TaskManager, "#start" do
  context "Given an webdriver, an valid foodtrucks URL, and a corresponding json template" do
    it "should start crawling" do
      url = "http://www.seattlefoodtruck.com"
      driver = WebdriverProxy.new :chrome

      template = JSON.parse(readfile("../template/foodtruckhome.json"))
      template["next_steps"] = nil
    
      task_manager = TaskManager.new(webdriver: driver, urls: url, templates: template, aggregator: MockAggregator.new)
      task_manager.start
      driver.close
    end
  end
end

RSpec.describe TaskManager, "#start" do
  context "Given a valid foodtrucks URL, and two corresponding json template" do
    it "should start crawling multiple pages" do
      url = "http://www.seattlefoodtruck.com"
      driver = WebdriverProxy.new :chrome

      templates = []
      templates = [JSON.parse(readfile("/data/foodtruckhome.json")), JSON.parse(readfile("/data/foodtruck.json"))]

      task_manager = TaskManager.new(webdriver: driver, urls: url, templates: templates, aggregator: MockAggregator.new)
      task_manager.start
      driver.close
    end
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

class MockAggregator

  def count
    1
  end

  def aggregate obj
  end

  def has_crawled url
    true
  end
end
