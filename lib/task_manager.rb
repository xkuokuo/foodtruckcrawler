#!/usr/bin/env ruby
require 'pry'
require_relative 'template_crawler'
require_relative 'simple_file_aggregator'

class TaskManager
  def initialize(webdriver:, urls:, templates:, limit: 100, aggregator:)
    @webdriver = webdriver
    @urls = urls
    @templates = templates
    @limit= limit
    @aggregator = aggregator
  end

  def start()
    submit(@urls, @templates)
  end

  def submit(urls, templates)
    puts "Crawling urls: #{urls}"
    if @aggregator.count > @limit
      puts "reached crawling limit #{@limit}"
      return false
    end
    if urls.respond_to?("each")
      urls.each do |url|
        if @aggregator.has_crawled(url)
          next
        end
        template = find_templates_for_url(url, templates)
        crawler = TemplateCrawler.new(@webdriver)
        res =  crawler.crawl(url, template)
        @aggregator.aggregate(res)
        if res[:next_steps].present?
          res[:next_steps].each do |next_url|
            if submit(next_url, find_templates_for_url(next_url, templates))
              sleep(1)
            end
          end
        end
      end
    else 
      if @aggregator.has_crawled(urls)
        return false
      end
      template = find_templates_for_url(urls, templates)
      crawler = TemplateCrawler.new(@webdriver)
      res = crawler.crawl(urls, template)
      @aggregator.aggregate(res)
      if res[:next_steps].present?
        res[:next_steps].each do |next_url|
          if submit(next_url, find_templates_for_url(next_url, templates))
            sleep(1)
          end
        end
      end
    end
    return true
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
      raise "No template find for url! #{url}"
    end
    res
  end

end
