require "rails_helper"

RSpec.describe Reports::MonthlySummary, type: :service do
  let(:user) { create(:user) }
  let(:income_category) { create(:category, user: user, name: "Salary") }
  let(:expense_category) { create(:category, user: user, name: "Food") }

  it "returns monthly totals scoped by user and month" do
    create(:transaction, :income, user: user, category: income_category, amount: 3000, date: Date.new(2026, 3, 2))
    create(:transaction, :expense, user: user, category: expense_category, amount: 1250, date: Date.new(2026, 3, 12))
    create(:transaction, :income, user: user, category: income_category, amount: 9999, date: Date.new(2026, 2, 1))

    summary = described_class.new(user: user, reference_date: Date.new(2026, 3, 1)).call

    expect(summary[:month]).to eq("2026-03")
    expect(summary[:income]).to eq(3000)
    expect(summary[:expenses]).to eq(1250)
    expect(summary[:balance]).to eq(1750)
  end
end
