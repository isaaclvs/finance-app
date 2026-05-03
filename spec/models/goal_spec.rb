require 'rails_helper'

RSpec.describe Goal, type: :model do
  let(:user) { create(:user) }

  describe "business logic - progress tracking" do
    let(:goal) { create(:goal, user: user, target_amount: 1000, current_amount: 250) }

    describe "#progress_percentage" do
      it "calculates correct percentage" do
        expect(goal.progress_percentage).to eq(25.0)
      end

      it "returns 0 when target_amount is 0" do
        goal.update(target_amount: 0)
        expect(goal.progress_percentage).to eq(0)
      end

      it "caps at 100%" do
        goal.update(current_amount: 1500)
        expect(goal.progress_percentage).to eq(100.0)
      end
    end

    describe "#remaining_amount" do
      it "calculates remaining amount" do
        expect(goal.remaining_amount).to eq(750)
      end

      it "returns 0 when current >= target" do
        goal.update(current_amount: 1200)
        expect(goal.remaining_amount).to eq(0)
      end
    end
  end

  describe "business logic - status methods" do
    describe "#completed?" do
      it "returns true when status is completed" do
        goal = create(:goal, user: user, status: "completed")
        expect(goal.completed?).to be true
      end

      it "returns true when current_amount >= target_amount" do
        goal = create(:goal, user: user, current_amount: 1000, target_amount: 1000, status: "active")
        expect(goal.completed?).to be true
      end
    end

    describe "rolled_over status" do
      let(:goal) do
        g = build(:goal, :rolled_over, user: user, current_amount: 3000, target_amount: 10000)
        g.save!(validate: false)
        g
      end

      it "#completed? returns false when amounts don't reach target" do
        expect(goal.completed?).to be false
      end

      it "#overdue? returns false" do
        expect(goal.overdue?).to be false
      end

      it "#due_soon? returns false" do
        expect(goal.due_soon?).to be false
      end

      it "#rollover! returns false" do
        expect(goal.rollover!).to be false
      end

      it "update_progress does not transition to completed" do
        goal.update_progress(goal.target_amount)
        expect(goal.reload.status).to eq("rolled_over")
      end
    end
  end

  describe "useful scopes" do
    before do
      create(:goal, user: user, status: "active", target_date: 1.week.from_now)
      create(:goal, user: user, status: "completed", target_date: Date.current)
    end

    describe ".active_goals" do
      it "returns only active goals" do
        expect(Goal.active_goals.count).to eq(1)
      end
    end

    describe ".completed_goals" do
      it "returns only completed goals" do
        expect(Goal.completed_goals.count).to eq(1)
      end
    end
  end

  describe "recurring goals" do
    describe "#rollover!" do
      it "creates a new goal for the next month" do
        goal = create(:goal, :recurring, user: user)
        next_cycle = goal.rollover!

        expect(next_cycle).to be_persisted
        expect(next_cycle.period_start).to eq(goal.period_end.next_month.beginning_of_month)
        expect(next_cycle.period_end).to eq(next_cycle.period_start.end_of_month)
        expect(next_cycle.current_amount).to eq(0.0)
        expect(next_cycle.recurring).to be true
        expect(next_cycle.user_id).to eq(goal.user_id)
      end

      it "marks the current goal as rolled_over" do
        goal = create(:goal, :recurring, user: user)
        goal.rollover!

        expect(goal.reload.status).to eq("rolled_over")
      end

      it "sets parent_goal_id pointing to the root ancestor" do
        root = create(:goal, :recurring, user: user)
        cycle1 = root.rollover!
        cycle2 = cycle1.rollover!

        expect(cycle1.parent_goal_id).to eq(root.id)
        expect(cycle2.parent_goal_id).to eq(root.id)
      end

      it "returns false for non-recurring goals" do
        goal = create(:goal, user: user, recurring: false)
        expect(goal.rollover!).to be false
      end

      it "returns false when goal is not active" do
        goal = create(:goal, :recurring, :paused, user: user)
        expect(goal.rollover!).to be false
      end
    end

    describe ".pending_rollover" do
      it "returns recurring active goals with period_end in the past" do
        past_goal = create(:goal, :recurring, user: user,
                           period_end: 1.day.ago, status: "active")
        create(:goal, :recurring, user: user, status: "active")
        create(:goal, :recurring, user: user, period_end: 1.day.ago, status: "paused")

        expect(Goal.pending_rollover).to contain_exactly(past_goal)
      end
    end

    describe "before_create callback" do
      it "sets period_start and period_end from target_date when recurring" do
        target = Date.new(2026, 6, 15)
        goal = create(:goal, user: user, recurring: true,
                      target_date: target, period_start: nil, period_end: nil)

        expect(goal.period_start).to eq(Date.new(2026, 6, 1))
        expect(goal.period_end).to eq(Date.new(2026, 6, 30))
      end

      it "does not set period dates for non-recurring goals" do
        goal = create(:goal, user: user, recurring: false,
                      target_date: 1.year.from_now, period_start: nil, period_end: nil)

        expect(goal.period_start).to be_nil
        expect(goal.period_end).to be_nil
      end
    end

    describe "associations" do
      it "links child goals to parent" do
        parent = create(:goal, :recurring, user: user)
        child = create(:goal, :recurring, user: user, parent_goal_id: parent.id)

        expect(parent.child_goals).to include(child)
        expect(child.parent_goal).to eq(parent)
      end
    end
  end

  describe "goal progress integration" do
    let(:category) { create(:category, user: user) }
    let(:goal) { create(:goal, user: user, category: category, target_amount: 1000, current_amount: 0) }

    it "can track progress when transactions are added" do
      create(:transaction, :income, user: user, category: category, amount: 300)

      # Simulate updating goal progress (would be done by controller/service)
      goal.update(current_amount: user.transactions.where(category: category).sum(:amount))

      expect(goal.progress_percentage).to eq(30.0)
      expect(goal.remaining_amount).to eq(700.0)
      expect(goal.completed?).to be false
    end

    it "detects completion when target is reached" do
      create(:transaction, :income, user: user, category: category, amount: 1000)

      # Simulate updating goal progress
      goal.update(current_amount: user.transactions.where(category: category).sum(:amount))

      expect(goal.progress_percentage).to eq(100.0)
      expect(goal.completed?).to be true
    end
  end
end
