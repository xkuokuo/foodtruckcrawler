require 'json'
require 'webdriver_proxy'
require 'task_manager'

RSpec.describe TaskManager, "#start" do
  context "Given an webdriver, an valid foodtrucks URL, and a corresponding json template" do
    it "should start crawling" do
      url = "http://www.seattlefoodtruck.com"
      driver = WebdriverProxy.new :chrome

      template_str = ""
      File.open(File.dirname(__FILE__) +"/data/foodtrucks.json") do |f|
        f.each_line do |line|
          template_str = template_str + line
        end
      end
      template = [JSON.parse(template_str)]

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

      template_str = ""
      File.open(File.dirname(__FILE__) +"/data/foodtrucks.json") do |f|
        f.each_line do |line|
          template_str = template_str + line
        end
      end
      template = JSON.parse(template_str)

      task_manager = TaskManager.new(webdriver: driver, urls: url, templates: template)
      expect {task_manager.start}.to raise_error
      driver.close
    end
  end
end
