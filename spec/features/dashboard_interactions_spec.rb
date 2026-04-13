require "rails_helper"

RSpec.describe "Dashboard interactions", type: :feature do
  let(:user) { create(:user, email: "dashboard@example.com", password: "password123", password_confirmation: "password123") }
  let!(:expense_category) { create(:category, user: user, name: "Food", color: "#EF4444") }
  let!(:income_category) { create(:category, user: user, name: "Salary", color: "#10B981") }

  before do
    create(:transaction, :expense, user: user, category: expense_category, amount: 20, description: "Coffee beans", date: Date.current)
    create(:transaction, :income, user: user, category: income_category, amount: 2000, description: "Monthly salary", date: Date.current)
    create(:transaction, :income, user: user, category: income_category, amount: 1500, description: "Previous month salary", date: 1.month.ago.beginning_of_month + 2.days)
    create(:transaction, :expense, user: user, category: expense_category, amount: 50, description: "Previous month groceries", date: 1.month.ago.beginning_of_month + 4.days)

    visit "/users/sign_in"
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password123"
    click_button "Sign in"
  end

  it "shows dashboard data and keeps filter params in export link" do
    visit "/dashboard?transaction_type=expense&period=month"

    currency = ActionController::Base.helpers.method(:number_to_currency)

    expect(page).to have_content("Dashboard")
    expect(page).to have_content("Coffee beans")
    expect(page).to have_content("vs")
    expect(page).to have_content("Up #{currency.call(500)}")
    expect(page).to have_content("Down #{currency.call(30)}")

    export_href = find_link("Export CSV")[:href]
    expect(export_href).to include("format=csv")
    expect(export_href).to include("transaction_type=expense")
    expect(export_href).to include("period=month")
  end

  it "renders mobile and desktop transaction containers" do
    visit "/transactions"

    expect(page).to have_css("#transactions-mobile", visible: :all)
    expect(page).to have_css(".hidden.md\\:block", visible: :all)
  end
end
