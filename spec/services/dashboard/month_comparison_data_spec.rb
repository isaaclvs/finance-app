require "rails_helper"

RSpec.describe Dashboard::MonthComparisonData, type: :service do
  let(:user) { create(:user) }
  let(:income_category) { create(:category, user: user, name: "Salary") }
  let(:expense_category) { create(:category, user: user, name: "Food") }
  let(:reference_date) { Date.new(2026, 4, 15) }

  it "returns current and previous month values with absolute and percentage deltas" do
    create(:transaction, :income, user: user, category: income_category, amount: 3000, date: Date.new(2026, 4, 3))
    create(:transaction, :expense, user: user, category: expense_category, amount: 900, date: Date.new(2026, 4, 8))
    create(:transaction, :income, user: user, category: income_category, amount: 2400, date: Date.new(2026, 3, 4))
    create(:transaction, :expense, user: user, category: expense_category, amount: 600, date: Date.new(2026, 3, 10))

    result = described_class.new(scope: user.transactions, reference_date: reference_date).call

    expect(result[:current_month_label]).to eq("Apr 2026")
    expect(result[:previous_month_label]).to eq("Mar 2026")

    expect(result[:metrics][:income]).to include(
      current_amount: 3000,
      previous_amount: 2400,
      absolute_change: 600,
      direction: :up
    )
    expect(result[:metrics][:income][:percentage_change]).to be_within(0.01).of(25.0)

    expect(result[:metrics][:expenses]).to include(
      current_amount: 900,
      previous_amount: 600,
      absolute_change: 300,
      direction: :up
    )
    expect(result[:metrics][:expenses][:percentage_change]).to be_within(0.01).of(50.0)

    expect(result[:metrics][:balance]).to include(
      current_amount: 2100,
      previous_amount: 1800,
      absolute_change: 300,
      direction: :up
    )
    expect(result[:metrics][:balance][:percentage_change]).to be_within(0.01).of(16.66)
  end

  it "returns nil percentage when there is no previous month data" do
    create(:transaction, :income, user: user, category: income_category, amount: 1500, date: Date.new(2026, 4, 3))

    result = described_class.new(scope: user.transactions, reference_date: reference_date).call

    expect(result[:metrics][:income][:previous_amount]).to eq(0)
    expect(result[:metrics][:income][:percentage_change]).to be_nil
    expect(result[:metrics][:income][:direction]).to eq(:up)
  end
end
