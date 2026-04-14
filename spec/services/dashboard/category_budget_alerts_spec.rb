require "rails_helper"

RSpec.describe Dashboard::CategoryBudgetAlerts, type: :service do
  let(:user) { create(:user) }
  let(:food_category) { create(:category, user: user, name: "Food", monthly_budget_limit: 100) }
  let(:transport_category) { create(:category, user: user, name: "Transport", monthly_budget_limit: 200) }
  let(:salary_category) { create(:category, user: user, name: "Salary", monthly_budget_limit: 3000) }

  describe "#call" do
    it "returns warning and exceeded alerts based on expense percentages" do
      create(:transaction, :expense, user: user, category: food_category, amount: 80, date: Date.current)
      create(:transaction, :expense, user: user, category: transport_category, amount: 250, date: Date.current)
      create(:transaction, :income, user: user, category: salary_category, amount: 4000, date: Date.current)

      alerts = described_class.new(
        scope: user.transactions.by_month(Date.current),
        categories: user.categories
      ).call

      expect(alerts.map { |alert| [ alert.category.name, alert.level, alert.percentage ] }).to eq(
        [
          [ "Transport", :exceeded, 125.0 ],
          [ "Food", :warning, 80.0 ]
        ]
      )
    end

    it "ignores categories without monthly budget limit or below threshold" do
      uncapped_category = create(:category, user: user, name: "Health", monthly_budget_limit: nil)
      create(:transaction, :expense, user: user, category: uncapped_category, amount: 500, date: Date.current)
      create(:transaction, :expense, user: user, category: transport_category, amount: 120, date: Date.current)

      alerts = described_class.new(
        scope: user.transactions.by_month(Date.current),
        categories: user.categories
      ).call

      expect(alerts).to be_empty
    end

    it "respects the provided filtered scope" do
      create(:transaction, :expense, user: user, category: food_category, amount: 90, date: Date.current)
      create(:transaction, :expense, user: user, category: food_category, amount: 120, date: 2.months.ago)

      current_month_alerts = described_class.new(
        scope: user.transactions.by_month(Date.current),
        categories: [ food_category ]
      ).call

      all_time_alerts = described_class.new(
        scope: user.transactions,
        categories: [ food_category ]
      ).call

      expect(current_month_alerts.first.percentage).to eq(90.0)
      expect(all_time_alerts.first.percentage).to eq(210.0)
    end
  end
end
