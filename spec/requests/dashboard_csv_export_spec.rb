require "rails_helper"
require "csv"

RSpec.describe "Dashboard CSV export", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:food) { create(:category, user: user, name: "Food") }
  let(:salary) { create(:category, user: user, name: "Salary") }
  let(:other_category) { create(:category, user: other_user, name: "Other") }

  before do
    sign_in_user(user)

    create(:transaction, :expense, user: user, category: food, amount: 25, description: "Coffee", date: Date.current)
    create(:transaction, :income, user: user, category: salary, amount: 2000, description: "Paycheck", date: Date.current)
    create(:transaction, :income, user: other_user, category: other_category, amount: 9999, description: "Should not export", date: Date.current)
  end

  it "exports only current user transactions in CSV format" do
    get "/dashboard.csv"

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("text/csv")

    parsed = CSV.parse(response.body, headers: true)
    descriptions = parsed.map { |row| row["Description"] }

    expect(descriptions).to include("Coffee", "Paycheck")
    expect(descriptions).not_to include("Should not export")
  end

  it "applies transaction_type filter to exported CSV" do
    get "/dashboard.csv", params: { transaction_type: "income" }

    parsed = CSV.parse(response.body, headers: true)
    types = parsed.map { |row| row["Type"] }.uniq

    expect(types).to eq([ "income" ])
    expect(parsed.map { |row| row["Description"] }).to include("Paycheck")
    expect(parsed.map { |row| row["Description"] }).not_to include("Coffee")
  end

  it "applies custom date range filter to exported CSV" do
    old_transaction = create(
      :transaction,
      :expense,
      user: user,
      category: food,
      amount: 10,
      description: "Old expense",
      date: 3.months.ago.to_date
    )

    get "/dashboard.csv", params: {
      period: "custom",
      start_date: Date.current.beginning_of_month,
      end_date: Date.current.end_of_month
    }

    parsed = CSV.parse(response.body, headers: true)
    descriptions = parsed.map { |row| row["Description"] }

    expect(descriptions).not_to include(old_transaction.description)
    expect(descriptions).to include("Coffee", "Paycheck")
  end
end
