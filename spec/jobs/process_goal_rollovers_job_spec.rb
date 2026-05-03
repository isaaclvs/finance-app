require 'rails_helper'

RSpec.describe ProcessGoalRolloversJob, type: :job do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "#perform" do
    it "calls rollover! on each goal pending rollover" do
      goal = create(:goal, :recurring, user: user,
                    period_end: 1.day.ago, status: "active")

      expect { described_class.perform_now }
        .to change { Goal.count }.by(1)
        .and change { goal.reload.status }.to("rolled_over")
    end

    it "creates a new active cycle for each rolled-over goal" do
      period_end = 1.day.ago.to_date
      create(:goal, :recurring, user: user, period_end: period_end, status: "active")

      described_class.perform_now

      new_cycle = Goal.last
      expect(new_cycle.status).to eq("active")
      expect(new_cycle.current_amount).to eq(0.0)
      expect(new_cycle.period_start).to eq(period_end.next_month.beginning_of_month)
    end

    it "does not rollover goals from other users inadvertently" do
      create(:goal, :recurring, user: user, period_end: 1.day.ago, status: "active")
      create(:goal, :recurring, user: other_user, period_end: 1.day.ago, status: "active")

      expect { described_class.perform_now }
        .to change { Goal.count }.by(2)
    end

    it "does not rollover non-recurring goals" do
      create(:goal, user: user, recurring: false, period_end: 1.day.ago, status: "active")

      expect { described_class.perform_now }.not_to change { Goal.count }
    end

    it "does not rollover goals with future period_end" do
      create(:goal, :recurring, user: user, period_end: 1.month.from_now, status: "active")

      expect { described_class.perform_now }.not_to change { Goal.count }
    end

    it "is idempotent — does not re-rollover already rolled-over goals" do
      goal = build(:goal, :rolled_over, user: user, period_end: 1.day.ago)
      goal.save!(validate: false)

      expect { described_class.perform_now }.not_to change { Goal.count }
    end
  end
end
