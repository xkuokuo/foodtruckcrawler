#!/usr/bin/env ruby
require 'pry'
require_relative('webdriver_proxy')

#Given a json template an da url, return the fetched result
class JsonCrawler
  def initialize(webdriver)
    @webdriver = webdriver
  end

  def crawl(url, template)
    #binding.pry
    @webdriver.goto url
    component_name = template["component_name"]
    xpath = template["xpath"]
    res = @webdriver.find_elements_by_xpath(xpath)
    return res.map {|result| result.text}
  end
end

if __FILE__ == $0
  driver = WebdriverProxy.new :chrome
  driver.goto "http://www.google.com"
end
