require "rails_helper"

RSpec.describe Dashboard::ChartsData, type: :service do
  let(:user) { create(:user) }
  let(:income_category) { create(:category, user: user, name: "Salary") }
  let(:food_category) { create(:category, user: user, name: "Food") }

  before do
    create(:transaction, :income, user: user, category: income_category, amount: 3000, date: Date.current)
    create(:transaction, :expense, user: user, category: food_category, amount: 500, date: Date.current)
    create(:transaction, :expense, user: user, category: food_category, amount: 250, date: Date.current)
  end

  it "returns aggregated chart data" do
    data = described_class.new(scope: user.transactions).call

    expect(data[:income_vs_expenses]).to eq(
      "Income" => 3000,
      "Expenses" => 750
    )

    expect(data[:expenses_by_category]).to eq(
      "Food" => 750
    )
  end
end
