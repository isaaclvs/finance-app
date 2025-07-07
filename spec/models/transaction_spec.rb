require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
  end
  
  describe 'delegations' do
    it { should delegate_method(:name).to(:category).with_prefix }
    it { should delegate_method(:color).to(:category).with_prefix }
  end
  
  describe 'enums' do
    it { should define_enum_for(:transaction_type).backed_by_column_of_type(:string).with_values(income: "income", expense: "expense") }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:transaction_type) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:user) }
  end
  
  describe 'scopes' do
    let(:user) { create(:user) }
    let(:category) { create(:category, user: user) }
    
    describe '.ordered' do
      it 'returns transactions ordered by date desc, created_at desc' do
        transaction1 = create(:transaction, date: 2.days.ago, user: user, category: category, created_at: 1.hour.ago)
        transaction2 = create(:transaction, date: 1.day.ago, user: user, category: category)
        transaction3 = create(:transaction, date: 2.days.ago, user: user, category: category, created_at: 2.hours.ago)
        
        expect(Transaction.ordered).to eq([transaction2, transaction1, transaction3])
      end
    end
    
    describe '.by_month' do
      it 'returns transactions for the given month' do
        transaction_this_month = create(:transaction, date: Date.current, user: user, category: category)
        transaction_last_month = create(:transaction, date: 1.month.ago, user: user, category: category)
        
        expect(Transaction.by_month(Date.current)).to include(transaction_this_month)
        expect(Transaction.by_month(Date.current)).not_to include(transaction_last_month)
      end
    end
    
    describe '.by_type' do
      it 'returns transactions of the specified type' do
        income = create(:transaction, :income, user: user, category: category)
        expense = create(:transaction, :expense, user: user, category: category)
        
        expect(Transaction.by_type('income')).to include(income)
        expect(Transaction.by_type('income')).not_to include(expense)
      end
    end
  end
  
  describe 'class methods' do
    let(:user) { create(:user) }
    let(:category) { create(:category, user: user) }
    
    describe '.balance' do
      it 'calculates the balance correctly' do
        create(:transaction, :income, amount: 1000, user: user, category: category)
        create(:transaction, :expense, amount: 300, user: user, category: category)
        
        expect(user.transactions.balance).to eq(700)
      end
    end
    
    describe '.total_by_type' do
      it 'returns the total for the specified type' do
        create(:transaction, :income, amount: 500, user: user, category: category)
        create(:transaction, :income, amount: 300, user: user, category: category)
        create(:transaction, :expense, amount: 200, user: user, category: category)
        
        expect(user.transactions.total_by_type('income')).to eq(800)
        expect(user.transactions.total_by_type('expense')).to eq(200)
      end
    end
  end
  
  describe 'instance methods' do
    describe '#income?' do
      it 'returns true for income transactions' do
        transaction = build(:transaction, :income)
        expect(transaction.income?).to be true
      end
      
      it 'returns false for expense transactions' do
        transaction = build(:transaction, :expense)
        expect(transaction.income?).to be false
      end
    end
    
    describe '#expense?' do
      it 'returns true for expense transactions' do
        transaction = build(:transaction, :expense)
        expect(transaction.expense?).to be true
      end
      
      it 'returns false for income transactions' do
        transaction = build(:transaction, :income)
        expect(transaction.expense?).to be false
      end
    end
    
    describe '#formatted_amount' do
      it 'formats income with + sign' do
        transaction = build(:transaction, :income, amount: 100.50)
        expect(transaction.formatted_amount).to eq('+$100.50')
      end
      
      it 'formats expense with - sign' do
        transaction = build(:transaction, :expense, amount: 50.25)
        expect(transaction.formatted_amount).to eq('-$50.25')
      end
    end
  end
end
