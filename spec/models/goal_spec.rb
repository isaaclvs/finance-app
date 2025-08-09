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
end