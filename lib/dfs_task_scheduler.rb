require 'set'

class DfsTaskScheduler 
  def initialize
    @queue = []
    @set = Set.new
  end

  def add_tasks tasks
    if tasks.respond_to?("each")
      tasks.each { |task|
        add_task task
      }
    else
      add_task tasks
    end
  end

  def add_task task
    if !@set.include?(task)
      @set.add(task)
      @queue.push(task)
    end
  end

  def get_task
    task = @queue.pop
    @set.delete?(task)
    task
  end

  def has_next?
    !@queue.empty?
  end
end
