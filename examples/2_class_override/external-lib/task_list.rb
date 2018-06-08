Task, Interfacer = import('external-lib/registry').grab(:Task, :Interfacer)

class TaskList
  extend Interfacer

  attribute(:task_class, :new) { Task }

  def tasks
    @tasks ||= Array.new
  end

  def <<(text)
    self.tasks << Task.new(text)
  end
end

export { TaskList }
