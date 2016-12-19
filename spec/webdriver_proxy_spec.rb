require 'webdriver_proxy'

RSpec.describe WebdriverProxy, "#goto" do
  context "Given an valid URL" do
    it "should navigate to the url and open the page succesfuly" do
      url = "http://www.gogle.com"
      driver = WebdriverProxy.new :chrome
      driver.goto url
      expect(driver.title).to eq "Google"
      driver.close
    end
  end
end
