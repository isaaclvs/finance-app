class ProcessGoalRolloversJob < ApplicationJob
  queue_as :default

  def perform
    Goal.pending_rollover.find_each(&:rollover!)
  end
end
