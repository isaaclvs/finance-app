require 'rails_helper'

RSpec.describe Goal, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:category).optional }
  end

  describe 'validations' do
    subject { build(:goal) }

    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:target_date) }
    it { should validate_presence_of(:goal_type) }
    it { should validate_presence_of(:status) }
    it { should validate_numericality_of(:target_amount).is_greater_than(0) }
    it { should validate_numericality_of(:current_amount).is_greater_than_or_equal_to(0) }

    context 'target_date validations' do
      it 'validates target_date cannot be in the past on create' do
        goal = build(:goal, target_date: 1.day.ago)
        expect(goal).to be_invalid
        expect(goal.errors[:target_date]).to include("can't be in the past")
      end

      it 'allows target_date in the future' do
        goal = build(:goal, target_date: 1.day.from_now)
        expect(goal).to be_valid
      end

      it 'allows target_date today' do
        goal = build(:goal, target_date: Date.current)
        expect(goal).to be_valid
      end
    end

    context 'current_amount validations' do
      it 'validates current_amount cannot exceed target_amount' do
        goal = build(:goal, target_amount: 1000, current_amount: 1500)
        expect(goal).to be_invalid
        expect(goal.errors[:current_amount]).to include("can't be greater than target amount")
      end

      it 'allows current_amount equal to target_amount' do
        goal = build(:goal, target_amount: 1000, current_amount: 1000)
        expect(goal).to be_valid
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:goal_type).with_values(
      savings: "savings",
      expense_reduction: "expense_reduction",
      income_increase: "income_increase",
      debt_payoff: "debt_payoff"
    ).backed_by_column_of_type(:string)}

    it { should define_enum_for(:status).with_values(
      active: "active",
      completed: "completed",
      paused: "paused",
      cancelled: "cancelled"
    ).backed_by_column_of_type(:string)}
  end

  describe 'scopes' do
    let!(:active_goal) { create(:goal, :savings, status: 'active') }
    let!(:completed_goal) { create(:goal, :completed) }
    let!(:overdue_goal) {
      goal = create(:goal, status: 'active')
      goal.update_column(:target_date, 1.month.ago)  # Bypass validation
      goal.reload
    }
    let!(:due_soon_goal) { create(:goal, :due_soon) }

    describe '.ordered' do
      it 'orders by target_date then created_at' do
        goals = described_class.ordered
        expect(goals.first).to eq(overdue_goal)
      end
    end

    describe '.active_goals' do
      it 'returns only active goals' do
        expect(described_class.active_goals).to contain_exactly(active_goal, overdue_goal, due_soon_goal)
      end
    end

    describe '.completed_goals' do
      it 'returns only completed goals' do
        expect(described_class.completed_goals).to contain_exactly(completed_goal)
      end
    end

    describe '.overdue' do
      it 'returns only overdue active goals' do
        expect(described_class.overdue).to contain_exactly(overdue_goal)
      end
    end

    describe '.due_soon' do
      it 'returns goals due within a week' do
        expect(described_class.due_soon).to contain_exactly(due_soon_goal)
      end
    end
  end

  describe 'Progressable concern' do
    let(:goal) { create(:goal, target_amount: 1000, current_amount: 250) }

    describe '#progress_percentage' do
      it 'calculates correct percentage' do
        expect(goal.progress_percentage).to eq(25.0)
      end

      it 'returns 0 when target_amount is 0' do
        goal.update(target_amount: 0)
        expect(goal.progress_percentage).to eq(0.0)
      end

      it 'caps at 100%' do
        goal.update(current_amount: 1500)
        expect(goal.progress_percentage).to eq(100.0)
      end
    end

    describe '#remaining_amount' do
      it 'calculates remaining amount' do
        expect(goal.remaining_amount).to eq(750)
      end

      it 'returns 0 when current >= target' do
        goal.update(current_amount: 1000)
        expect(goal.remaining_amount).to eq(0)
      end
    end

    describe '#update_progress' do
      it 'updates current_amount' do
        expect(goal.update_progress(500)).to be true
        expect(goal.reload.current_amount).to eq(500)
      end

      it 'prevents negative amounts' do
        expect(goal.update_progress(-100)).to be true
        expect(goal.reload.current_amount).to eq(0)
      end

      it 'marks as completed when target is reached' do
        goal.update_progress(1000)
        expect(goal.reload).to be_completed
      end
    end

    describe '#add_progress' do
      it 'adds to current amount' do
        expect(goal.add_progress(250)).to be true
        expect(goal.reload.current_amount).to eq(500)
      end
    end

    describe '#subtract_progress' do
      it 'subtracts from current amount' do
        expect(goal.subtract_progress(50)).to be true
        expect(goal.reload.current_amount).to eq(200)
      end
    end
  end

  describe 'instance methods' do
    let(:goal) { create(:goal, target_amount: 1000, current_amount: 750) }

    describe '#overdue?' do
      it 'returns false for future dates' do
        goal.update(target_date: 1.week.from_now)
        expect(goal).not_to be_overdue
      end

      it 'returns true for past dates with active status' do
        goal.update(target_date: 1.week.ago, status: 'active')
        expect(goal).to be_overdue
      end

      it 'returns false for past dates with non-active status' do
        goal.update(target_date: 1.week.ago, status: 'completed')
        expect(goal).not_to be_overdue
      end
    end

    describe '#due_soon?' do
      it 'returns true for dates within a week' do
        goal.update(target_date: 3.days.from_now)
        expect(goal).to be_due_soon
      end

      it 'returns false for dates beyond a week' do
        goal.update(target_date: 2.weeks.from_now)
        expect(goal).not_to be_due_soon
      end
    end

    describe '#completed?' do
      it 'returns true when status is completed' do
        goal.update(status: 'completed')
        expect(goal).to be_completed
      end

      it 'returns true when current_amount >= target_amount' do
        goal.update(current_amount: 1000)
        expect(goal).to be_completed
      end
    end

    describe '#can_complete?' do
      it 'returns true when current_amount >= target_amount' do
        goal.update(current_amount: 1000)
        expect(goal).to be_can_complete
      end

      it 'returns false when current_amount < target_amount' do
        expect(goal).not_to be_can_complete
      end
    end

    describe '#mark_completed!' do
      it 'marks goal as completed when target is reached' do
        goal.update(current_amount: 1000)
        goal.mark_completed!
        expect(goal.reload.status).to eq('completed')
      end

      it 'does not mark as completed when target is not reached' do
        goal.mark_completed!
        expect(goal.reload.status).to eq('active')
      end
    end

    describe '#days_remaining' do
      it 'calculates days until target_date' do
        goal.update(target_date: 5.days.from_now)
        expect(goal.days_remaining).to eq(5)
      end

      it 'returns 0 for overdue goals' do
        goal.update(target_date: 5.days.ago)
        expect(goal.days_remaining).to eq(0)
      end
    end

    describe '#goal_type_color' do
      it 'returns correct colors for each type' do
        expect(create(:goal, goal_type: 'savings').goal_type_color).to eq('emerald')
        expect(create(:goal, goal_type: 'expense_reduction').goal_type_color).to eq('red')
        expect(create(:goal, goal_type: 'income_increase').goal_type_color).to eq('blue')
        expect(create(:goal, goal_type: 'debt_payoff').goal_type_color).to eq('purple')
      end
    end

    describe '#status_color' do
      it 'returns correct colors for each status' do
        expect(create(:goal, status: 'active').status_color).to eq('blue')
        expect(create(:goal, status: 'completed').status_color).to eq('green')
        expect(create(:goal, status: 'paused').status_color).to eq('yellow')
        expect(create(:goal, status: 'cancelled').status_color).to eq('gray')
      end
    end
  end
end
