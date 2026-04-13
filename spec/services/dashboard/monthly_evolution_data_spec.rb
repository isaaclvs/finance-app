require "rails_helper"

RSpec.describe Dashboard::MonthlyEvolutionData, type: :service do
  let(:user) { create(:user) }
  let(:income_category) { create(:category, user: user, name: "Salary") }
  let(:expense_category) { create(:category, user: user, name: "Food") }

  it "returns six months with aggregated income and expenses" do
    create(:transaction, :income, user: user, category: income_category, amount: 1000, date: Date.current.beginning_of_month + 2.days)
    create(:transaction, :expense, user: user, category: expense_category, amount: 400, date: Date.current.beginning_of_month + 5.days)
    create(:transaction, :income, user: user, category: income_category, amount: 700, date: 1.month.ago.beginning_of_month + 1.day)

    result = described_class.new(scope: user.transactions).call

    expect(result.keys.size).to eq(6)
    expect(result[Date.current.beginning_of_month.strftime("%b %Y")]["Income"]).to eq(1000)
    expect(result[Date.current.beginning_of_month.strftime("%b %Y")]["Expenses"]).to eq(400)
    expect(result[1.month.ago.beginning_of_month.strftime("%b %Y")]["Income"]).to eq(700)
  end

  it "runs without N+1 style query amplification" do
    create_list(:transaction, 10, :income, user: user, category: income_category, date: Date.current)

    scope = user.transactions
    query_count = 0
    callback = lambda do |_name, _started, _finished, _unique_id, payload|
      query_count += 1 if payload[:sql] !~ /SCHEMA/
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      described_class.new(scope: scope).call
    end

    expect(query_count).to be <= 3
  end
end
