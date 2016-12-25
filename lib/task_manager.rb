#!/usr/bin/env ruby
require 'pry'
require 'set'
require 'thread'
require_relative 'template_crawler'
require_relative 'webdriver_proxy'
require_relative 'simple_file_aggregator'
require_relative 'dfs_task_scheduler'

class TaskManager
  def initialize(urls:, templates:, limit: 100, aggregator:, scheduler: DfsTaskScheduler.new)
    @templates = templates
    @limit= limit
    @aggregator = aggregator
    @logger = Logger.new STDOUT
    @scheduler = scheduler
    @scheduler.add_tasks(urls)
    @mutex = Mutex.new
    @signal = ConditionVariable.new
  end

  def start
    max_num_thread = 4
    thread_set = Set.new
    while true 
      #still need to run?
      if !@scheduler.has_next? && Thread.list.length == 1
        break
      end

      if @aggregator.count > @limit
        @logger.warn "reached crawling limit #{@limit}"
        break
      end

      #url = @scheduler.get_task
      #submit(url, @templates, @aggregator, @scheduler)
      #sleep 10

      #if reach threads limit, just wait for a random t to finish
      if Thread.list.length >= (max_num_thread + 1)
        @mutex.synchronize {
          @signal.wait @mutex
        }
      end
      (max_num_thread - Thread.list.length + 1).times {
        if @scheduler.has_next?
          url = @scheduler.get_task
          t = submit(url, @templates, @aggregator, @scheduler)
          sleep 0.2
        else
          break
        end
      }
    end
  end

  def submit(url, templates, aggregator, scheduler, retries = 5)
    @logger.info "Crawling url: #{url}"
    t = Thread.new {
      res = crawl_single_url(url, templates)
      scheduler.add_tasks(get_next_steps(res).select {|e| !aggregator.has_crawled(e)})
      aggregator.aggregate(res)
      @mutex.synchronize {
        @signal.signal 
      }
    }
    t
  end

  def crawl_single_url(url, templates)
    template = find_templates_for_url(url, templates)
    driver = WebdriverProxy.new :chrome
    crawler = TemplateCrawler.new(driver)
    res = crawler.crawl(url, template)
    driver.close
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
