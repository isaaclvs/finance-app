require "rails_helper"

RSpec.describe Dashboard::TransactionsFilter, type: :service do
  let(:user) { create(:user) }
  let(:income_category) { create(:category, user: user, name: "Salary") }
  let(:expense_category) { create(:category, user: user, name: "Food") }

  let!(:income_transaction) do
    create(:transaction, :income, user: user, category: income_category, description: "Monthly salary", amount: 2000, date: Date.current)
  end
  let!(:expense_transaction) do
    create(:transaction, :expense, user: user, category: expense_category, description: "Lunch", amount: 50, date: Date.current)
  end
  let!(:old_expense_transaction) do
    create(:transaction, :expense, user: user, category: expense_category, description: "Old lunch", amount: 30, date: 2.months.ago)
  end

  it "filters by type" do
    scope = described_class.new(scope: user.transactions, params: { transaction_type: "income" }).call

    expect(scope).to contain_exactly(income_transaction)
  end

  it "filters by category" do
    scope = described_class.new(scope: user.transactions, params: { category_id: expense_category.id }).call

    expect(scope).to include(expense_transaction, old_expense_transaction)
    expect(scope).not_to include(income_transaction)
  end

  it "filters by search" do
    scope = described_class.new(scope: user.transactions, params: { search: "salary" }).call

    expect(scope).to contain_exactly(income_transaction)
  end

  it "applies period filter when include_date_filter is true" do
    scope = described_class.new(scope: user.transactions, params: { period: "month" }).call

    expect(scope).to include(income_transaction, expense_transaction)
    expect(scope).not_to include(old_expense_transaction)
  end

  it "ignores period filter when include_date_filter is false" do
    scope = described_class.new(scope: user.transactions, params: { period: "month" }).call(include_date_filter: false)

    expect(scope).to include(old_expense_transaction)
  end
end
