#!/usr/bin/env ruby
require 'pry'
require 'nokogiri'
require 'active_support'
require 'active_support/core_ext'
require_relative 'webdriver_proxy'

#Given a json template an da url, return the fetched result
class TemplateCrawler
  def initialize(webdriver)
    @webdriver = webdriver
  end

  def crawl(url, template)
    @webdriver.goto url
    page_source = @webdriver.page_source
    doc = Nokogiri::HTML(page_source)
    next_steps = doc.xpath(template["next_steps"]).map {|step| step.value}
    res = {url: url, content: parse_doc(doc, template), next_steps: next_steps}
    res
  end

  def parse_doc(doc, template)
    name = template["name"]
    xpath = template["xpath"]
    display_or_not = template["display_or_not"]
    #elements = find_elements_by_xpath(page_source, xpath)
    elements = doc.xpath(xpath)
    children_template = template["children"]

    res = elements.map do |element|  
      content = nil
      if display_or_not
        if ((element.node_name.eql? "img") || (element.node_name.eql? "a")) then
          content = element.attribute("src").value
        else
          content = element.text
        end
      end
      tmpres = {name: name, content: content, children: nil}
      children = []
      if children_template.nil?
      elsif children_template.class == Array
        children_template.each do |child_template|
          children.push(parse_doc(element, child_template))
        end
      elsif children_template.class == Hash
        children.push(parse_doc(element, children_template))
      end
      tmpres[:children] = children.present? ? children : nil
      tmpres
    end
  end
  
  def find_elements_by_xpath(page_source, xpath) 
    doc = Nokogiri::HTML(page_source)
    return doc.xpath(xpath)
  end
end

if __FILE__ == $0
  driver = WebdriverProxy.new :chrome
  driver.goto "http://www.google.com"
end
