#!/usr/bin/env ruby
require 'pry'
require 'logger'
require_relative 'template_crawler'
require_relative 'simple_file_aggregator'
require_relative 'dfs_task_scheduler'

class TaskManager
  def initialize(webdriver:, urls:, templates:, limit: 100, aggregator:, scheduler: DfsTaskScheduler.new)
    @webdriver = webdriver
    @templates = templates
    @limit= limit
    @aggregator = aggregator
    @logger = Logger.new STDOUT
    @scheduler = scheduler
    @scheduler.add_tasks(urls)
  end

  def start()
    #while @urls.present?
    while @scheduler.has_next?
      url = @scheduler.get_task
      submit(url, @templates)
    end
  end

  def submit(url, templates, retries = 5)
    @logger.info "Crawling url: #{url}"
    if @aggregator.count > @limit
      @logger.warn "reached crawling limit #{@limit}"
      return false
    end
    res = crawl_single_url(url, templates, @aggregator)
    @scheduler.add_tasks(get_next_steps(res).select {|e| !@aggregator.has_crawled(e)})
    return true
  end

  def crawl_single_url(url, templates, aggregator, retries = 5)
    if !url.present? || aggregator.has_crawled(url)
      return nil
    end
    res = nil
    retries.times { |i|
      begin 
        template = find_templates_for_url(url, templates)
        crawler = TemplateCrawler.new(@webdriver)
        res =  crawler.crawl(url, template)
        break
      rescue Exception => e
        @logger.error "Unexpected error: #{e.message}\nTry again (#{retries - i - 1} tries remaining)"
      end
      if i >= retries 
        return
      end
    }
    aggregator.aggregate(res)
    sleep(1)
    res
  end

  def get_next_steps(crawl_res)
    if crawl_res.respond_to?("[]") && crawl_res[:next_steps].present?
      return crawl_res[:next_steps]
    end
    return []
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
