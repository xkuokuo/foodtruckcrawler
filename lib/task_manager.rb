#!/usr/bin/env ruby
require 'pry'
require 'template_crawler'

class TaskManager
  def initialize(webdriver:, urls:, templates:, depth: 10)
    @webdriver = webdriver
    @urls = urls
    @templates = templates
    @depth = depth
  end

  def start()
    puts "Let's start!"
    submit(@urls, @templates)
  end

  def submit(urls, templates)
    if urls.respond_to?("each")
      urls.each do |url|
        template = find_templates_for_url(url, templates)
        crawler = TemplateCrawler.new @webdriver
        res =  crawler.crawl(url, template)
        if res[:next_steps].present?
          res[:next_steps].each do |link|
            puts link
            @webdriver.goto link
            sleep(1)
          end
        end
      end
    else 
      template = find_templates_for_url(urls, templates)
      crawler = TemplateCrawler.new @webdriver
      res = crawler.crawl(urls, template)
      if res[:next_steps].present?
        res[:next_steps].each do |link|
          puts link
          @webdriver.goto link
          sleep(1)
        end
      end
    end
  end

  def find_templates_for_url(url, templates)
    res = nil
    if templates.class == Array
      templates.each do |template|
        regex = Regexp.new template["matched_url"]
        if regex =~ url
          res = template
        end
      end
    elsif templates.class == Hash
        regex = Regexp.new templates["matched_url"]
        if regex =~ url
          res = templates
        end
    end
    if res.nil?
      raise "No template find for url!"
    end
    res
  end

end
