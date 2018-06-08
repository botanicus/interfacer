#!/usr/bin/env ruby -Iexternal-lib -rbundler/setup

require 'import'

# Task, TaskList = import('registry').grab(:Task, :TaskList)
external_lib = import('external-lib')

list = external_lib.TaskList.new

list << "Make example 1"
list << "Make example 2"
list << "Make example 3"

p list

# ...
# Note: Task wasn't explicitly exposed, but what the hell.
class MyTask < external_lib.registry.Task
  def inspect
    "MY TASK <#{self.text}>"
  end
end

puts 
p [:t, external_lib.registry.Task]
external_lib.registry.Task = MyTask
p [:t, external_lib.registry.Task]

### HACK
key = Imports.register.find { |key, v| key.match(/external-lib\/task_list/) }.first
Imports.register.delete(key)
###

list = external_lib.TaskList.new

list << "Make example 1"
list << "Make example 2"
list << "Make example 3"

p list
