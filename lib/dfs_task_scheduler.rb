require 'set'

class DfsTaskScheduler 
  def initialize
    @queue = []
    @set = Set.new
    @mutex = Mutex.new
  end

  def add_tasks tasks
    @mutex.synchronize {
      if tasks.respond_to?("each")
        tasks.each { |task|
          add_task task
        }
      else
        add_task tasks
      end
    }
  end

  def add_task task
    if !has_tried?(task)
      @set.add(task)
      @queue.push(task)
    end
  end

  def get_task
    @mutex.synchronize {
      task = @queue.pop
      #@set.delete?(task)
    task
    }
  end

  def has_next?
    @mutex.synchronize {
      !@queue.empty?
    }
  end

  def has_tried? task
    @set.include?(task)
  end
end
