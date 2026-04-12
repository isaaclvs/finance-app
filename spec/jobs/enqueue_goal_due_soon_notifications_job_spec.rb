require "rails_helper"

RSpec.describe EnqueueGoalDueSoonNotificationsJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it "enqueues one notification job per due soon active goal" do
    due_soon_goal = create(:goal, :due_soon, user: user, category: category, status: "active")
    create(:goal, user: user, category: category, target_date: 1.month.from_now, status: "active")
    create(:goal, :due_soon, user: user, category: category, status: "paused")

    expect {
      described_class.perform_now
    }.to have_enqueued_job(GoalDueSoonNotificationJob).with(due_soon_goal.id).exactly(:once)
  end
end
