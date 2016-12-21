require 'json'
require 'webdriver_proxy'
require 'template_crawler'

RSpec.describe TemplateCrawler, "#crawl" do
  context "Given an valid foodtrucks URL and a corresponding json template" do
    it "should return the food truck info" do
      url = "http://www.seattlefoodtruck.com"
      driver = WebdriverProxy.new :chrome
      template_str = ""
      File.open(File.dirname(__FILE__) +"/data/foodtrucks.json") do |f|
        f.each_line do |line|
          template_str = template_str + line
        end
      end
      template = JSON.parse(template_str)
      template_crawler = TemplateCrawler.new driver
      template_crawler.crawl(url, template).to_json
      #expect(json_crawler.crawl(url, template).to_a).to match_array({name:"dummy"}.to_a)
      driver.close
    end
  end
end
