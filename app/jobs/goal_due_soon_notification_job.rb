class GoalDueSoonNotificationJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    goal = Goal.includes(:user).find_by(id: goal_id)
    return unless goal&.active? && goal.due_soon?

    GoalNotificationsMailer.due_soon(goal).deliver_now
  end
end
