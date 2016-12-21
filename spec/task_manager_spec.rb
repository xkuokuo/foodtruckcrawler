require 'json'
require 'pry'
require 'webdriver_proxy'
require 'task_manager'

RSpec.describe TaskManager, "#start" do
  context "Given an webdriver, an valid foodtrucks URL, and a corresponding json template" do
    it "should start crawling" do
      url = "http://www.seattlefoodtruck.com"
      driver = WebdriverProxy.new :chrome

      template = JSON.parse(readfile("/data/foodtruckhome.json"))
      template["next_steps"] = nil
    
      task_manager = TaskManager.new(webdriver: driver, urls: url, templates: template)
      task_manager.start
      driver.close
    end
  end
end

RSpec.describe TaskManager, "#start" do
  context "Given an in-valid foodtrucks URL" do
    it "should raise exception" do
      url = "http://www.seattlefoodtruck_invalid.com"
      driver = WebdriverProxy.new :chrome

      template = JSON.parse(readfile("/data/foodtruckhome.json"))

      task_manager = TaskManager.new(webdriver: driver, urls: url, templates: template)
      expect {task_manager.start}.to raise_error
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
      

      task_manager = TaskManager.new(webdriver: driver, urls: url, templates: templates)
      task_manager.start
      driver.close
    end
  end
end

def readfile(filename)
  res_str = ""
  File.open(File.dirname(__FILE__) +filename) do |f|
    f.each_line do |line|
      res_str = res_str + line
    end
  end
  res_str
end
