class Task
  attr_reader :text
  def initialize(text)
    @text = text
  end

  def inspect
    "Task: <#{text}>"
  end
end

export { Task }
