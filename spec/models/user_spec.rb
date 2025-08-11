require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }
  
  describe "financial calculations" do
    let!(:income_category) { create(:category, name: "Salary", user: user) }
    let!(:expense_category) { create(:category, name: "Food", user: user) }
    
    before do
      create(:transaction, :income, amount: 1000.0, user: user, category: income_category)
      create(:transaction, :income, amount: 500.0, user: user, category: income_category)
      create(:transaction, :expense, amount: 200.0, user: user, category: expense_category)
      create(:transaction, :expense, amount: 150.0, user: user, category: expense_category)
    end
    
    describe "#total_income" do
      it "calculates total income correctly" do
        expect(user.total_income).to eq(1500.0)
      end
    end
    
    describe "#total_expenses" do
      it "calculates total expenses correctly" do
        expect(user.total_expenses).to eq(350.0)
      end
    end
    
    describe "#balance" do
      it "calculates balance correctly" do
        expect(user.balance).to eq(1150.0)
      end
    end
    
    describe "#balance_data" do
      it "returns hash with all balance information" do
        data = user.balance_data
        expect(data).to include(
          income: 1500.0,
          expenses: 350.0,
          balance: 1150.0
        )
      end
    end
  end
  
  describe "monthly calculations" do
    let!(:category) { create(:category, user: user) }
    
    before do
      create(:transaction, :income, amount: 1000.0, user: user, category: category, date: Date.current)
      create(:transaction, :expense, amount: 200.0, user: user, category: category, date: Date.current)
      create(:transaction, :income, amount: 500.0, user: user, category: category, date: 1.month.ago)
    end
    
    describe "#monthly_income" do
      it "calculates income for current month" do
        expect(user.monthly_income).to eq(1000.0)
      end
      
      it "calculates income for specific month" do
        expect(user.monthly_income(1.month.ago)).to eq(500.0)
      end
    end
    
    describe "#monthly_balance" do
      it "calculates balance for current month" do
        expect(user.monthly_balance).to eq(800.0)
      end
    end
  end
  
  describe "data isolation" do
    let!(:other_user) { create(:user) }
    let!(:user_category) { create(:category, user: user) }
    let!(:other_user_category) { create(:category, user: other_user) }
    
    before do
      create(:transaction, :income, amount: 1000.0, user: user, category: user_category)
      create(:transaction, :income, amount: 2000.0, user: other_user, category: other_user_category)
    end
    
    it "only includes user's own transactions in balance calculations" do
      expect(user.total_income).to eq(1000.0)
      expect(other_user.total_income).to eq(2000.0)
    end
  end
  
  describe "balance calculation accuracy" do
    let(:category) { create(:category, user: user) }
    
    it "calculates balance correctly with mixed transactions" do
      create(:transaction, :income, user: user, category: category, amount: 1000)
      create(:transaction, :expense, user: user, category: category, amount: 300)
      create(:transaction, :income, user: user, category: category, amount: 500)
      create(:transaction, :expense, user: user, category: category, amount: 200)
      
      expect(user.balance).to eq(1000.0)
    end
  end
end