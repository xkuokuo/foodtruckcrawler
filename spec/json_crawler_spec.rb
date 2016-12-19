require 'webdriver_proxy'
require 'json_crawler'

RSpec.describe JsonCrawler, "#crawl" do
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
      json_crawler = JsonCrawler.new driver
      puts json_crawler.crawl(url, template)
      #expect(json_crawler.crawl(url, template).to_a).to match_array({name:"dummy"}.to_a)
      driver.close
    end
  end
end
