#!/usr/bin/env ruby
require 'pry'
require 'logger'
require_relative 'template_crawler'
require_relative 'simple_file_aggregator'

class TaskManager
  def initialize(webdriver:, urls:, templates:, limit: 100, aggregator:)
    @webdriver = webdriver
    @urls = urls
    @templates = templates
    @limit= limit
    @aggregator = aggregator
    @logger = Logger.new STDOUT
  end

  def start()
    submit(@urls, @templates)
  end

  def submit(urls, templates)
    @logger.info "Crawling urls: #{urls}"
    if @aggregator.count > @limit
      @logger.warn "reached crawling limit #{@limit}"
      return false
    end
    if urls.respond_to?("each")
      urls.each do |url|
        crawl_single_url(url, templates, @aggregator)
      end
    else 
      crawl_single_url(urls, templates, @aggregator)
    end
    return true
  end

  def crawl_single_url(url, templates, aggregator, retries = 5)
      if aggregator.has_crawled(url)
        return nil
      end
      template = find_templates_for_url(url, templates)
      res = nil
      crawler = TemplateCrawler.new(@webdriver)
      retries.times { |i|
        begin 
          res =  crawler.crawl(url, template)
          break
        rescue Exception => e
          puts "Unexpected error: #{e.message}\nTry again (#{retries - i - 1} tries remaining)"
        end
        if i >= retries 
          return
        end
      }
      aggregator.aggregate(res)
      sleep(1)
      if res[:next_steps].present?
        res[:next_steps].each do |next_url|
          submit(next_url, find_templates_for_url(next_url, templates))
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
      raise "No template find for url! #{url}"
    end
    res
  end
end
