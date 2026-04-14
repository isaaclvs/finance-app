require "rails_helper"

RSpec.describe "Dashboard interactions", type: :feature do
  let(:user) { create(:user, email: "dashboard@example.com", password: "password123", password_confirmation: "password123") }
  let!(:expense_category) { create(:category, user: user, name: "Food", color: "#EF4444", monthly_budget_limit: 25) }
  let!(:income_category) { create(:category, user: user, name: "Salary", color: "#10B981") }

  before do
    create(:transaction, :expense, user: user, category: expense_category, amount: 20, description: "Coffee beans", date: Date.current)
    create(:transaction, :income, user: user, category: income_category, amount: 2000, description: "Monthly salary", date: Date.current)
    create(:transaction, :income, user: user, category: income_category, amount: 1500, description: "Previous month salary", date: 1.month.ago.beginning_of_month + 2.days)
    create(:transaction, :expense, user: user, category: expense_category, amount: 50, description: "Previous month groceries", date: 1.month.ago.beginning_of_month + 4.days)

    visit "/users/sign_in"
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password123"
    click_button I18n.t("devise.views.sessions.new.submit")
  end

  it "shows dashboard data and keeps filter params in export link" do
    visit "/dashboard?transaction_type=expense&period=month"

    currency = ActionController::Base.helpers.method(:number_to_currency)
    current_label = Date.current.beginning_of_month.strftime("%b %Y")
    previous_label = 1.month.ago.beginning_of_month.strftime("%b %Y")

    expect(page).to have_content("Dashboard")
    expect(page).to have_content("Coffee beans")
    expect(page).to have_content("vs")
    expect(page).to have_content("#{I18n.t("shared.balance_summary.comparison.direction.up")} #{currency.call(500)}")
    expect(page).to have_content("#{I18n.t("shared.balance_summary.comparison.direction.down")} #{currency.call(30)}")
    expect(page).to have_content(
      I18n.t(
        "shared.balance_summary.comparison.values",
        current_month: current_label,
        current_amount: currency.call(2000),
        previous_month: previous_label,
        previous_amount: currency.call(1500)
      )
    )

    export_href = find_link(I18n.t("dashboard.index.export_csv"))[:href]
    expect(export_href).to include("format=csv")
    expect(export_href).to include("transaction_type=expense")
    expect(export_href).to include("period=month")
  end

  it "shows category budget alerts for the current month by default" do
    visit "/dashboard"

    expect(page).to have_content(I18n.t("dashboard.budget_alerts.title"))
    expect(page).to have_content("Food")
    expect(page).to have_content(I18n.t("dashboard.budget_alerts.levels.warning"))
    expect(page).to have_content(ActionController::Base.helpers.number_to_currency(20))
  end

  it "recalculates budget alerts when a period filter is applied" do
    visit "/dashboard?category_id=#{expense_category.id}&period=month"
    expect(page).to have_content(I18n.t("dashboard.budget_alerts.levels.warning"))

    visit "/dashboard?category_id=#{expense_category.id}&period=custom&start_date=#{1.month.ago.beginning_of_month}&end_date=#{1.month.ago.end_of_month}"

    expect(page).to have_content(I18n.t("dashboard.budget_alerts.levels.exceeded"))
    expect(page).to have_content(ActionController::Base.helpers.number_to_currency(50))
  end

  it "renders mobile and desktop transaction containers" do
    visit "/transactions"

    expect(page).to have_css("#transactions-mobile", visible: :all)
    expect(page).to have_css(".hidden.md\\:block", visible: :all)
  end

  it "shows fallback text when there is no previous month data" do
    user.transactions.where(date: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).delete_all

    visit "/dashboard"

    expect(page).to have_content(I18n.t("shared.balance_summary.comparison.new_period"))
  end
end
