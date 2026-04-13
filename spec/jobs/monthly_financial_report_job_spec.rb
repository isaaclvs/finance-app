require "rails_helper"

RSpec.describe MonthlyFinancialReportJob, type: :job do
  let(:user) { create(:user, email: "reports-job@example.com") }
  let(:income_category) { create(:category, user: user, name: "Salary") }
  let(:expense_category) { create(:category, user: user, name: "Food") }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it "sends a monthly report email with summary values" do
    create(:transaction, :income, user: user, category: income_category, amount: 2500, date: Date.new(2026, 3, 5))
    create(:transaction, :expense, user: user, category: expense_category, amount: 700, date: Date.new(2026, 3, 10))

    expect {
      described_class.perform_now(user.id, "2026-03-01")
    }.to change(ActionMailer::Base.deliveries, :count).by(1)

    email = ActionMailer::Base.deliveries.last
    expect(email.to).to contain_exactly(user.email)
    expect(email.subject).to include("2026-03")
    expect(email.body.encoded).to include("Income: R$ 2.500,00")
    expect(email.body.encoded).to include("Expenses: R$ 700,00")
    expect(email.body.encoded).to include("Balance: R$ 1.800,00")
  end

  it "falls back to previous month when reference month is invalid" do
    allow(Date).to receive(:current).and_return(Date.new(2026, 4, 20))

    create(:transaction, :income, user: user, category: income_category, amount: 1200, date: Date.new(2026, 3, 8))

    described_class.perform_now(user.id, "invalid-date")

    email = ActionMailer::Base.deliveries.last
    expect(email.subject).to include("2026-03")
  end
end
