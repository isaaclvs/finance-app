class GoalNotificationsMailer < ApplicationMailer
  def due_soon(goal)
    @goal = goal
    @user = goal.user

    mail(
      to: @user.email,
      subject: "Goal due soon: #{@goal.title}"
    )
  end
end
