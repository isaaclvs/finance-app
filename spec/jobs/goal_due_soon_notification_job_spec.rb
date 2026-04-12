require "rails_helper"

RSpec.describe GoalDueSoonNotificationJob, type: :job do
  let(:user) { create(:user, email: "goal-job@example.com") }
  let(:category) { create(:category, user: user) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it "sends email when goal is active and due soon" do
    goal = create(:goal, :due_soon, user: user, category: category, status: "active")

    expect {
      described_class.perform_now(goal.id)
    }.to change(ActionMailer::Base.deliveries, :count).by(1)

    email = ActionMailer::Base.deliveries.last
    expect(email.to).to contain_exactly(user.email)
    expect(email.subject).to include("Goal due soon")
    expect(email.body.encoded).to include(goal.title)
  end

  it "does not send email when goal is not due soon" do
    goal = create(:goal, user: user, category: category, target_date: 1.month.from_now)

    expect {
      described_class.perform_now(goal.id)
    }.not_to change(ActionMailer::Base.deliveries, :count)
  end
end
