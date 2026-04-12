class EnqueueGoalDueSoonNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    Goal.active_goals.due_soon.find_each do |goal|
      GoalDueSoonNotificationJob.perform_later(goal.id)
    end
  end
end
