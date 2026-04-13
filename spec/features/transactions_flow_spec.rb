require "rails_helper"

RSpec.describe "Transactions flow", type: :feature do
  let(:user) { create(:user, email: "transactions@example.com", password: "password123", password_confirmation: "password123") }
  let!(:category) { create(:category, user: user, name: "Salary", color: "#10B981") }

  before do
    visit "/users/sign_in"
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password123"
    click_button I18n.t("devise.views.sessions.new.submit")
  end

  it "creates and updates a transaction" do
    visit "/transactions/new"

    choose I18n.t("transactions.form.income"), allow_label_click: true
    fill_in "Amount", with: "123.45"
    fill_in "Date", with: Date.current
    select "Salary", from: I18n.t("transactions.form.category")
    fill_in "Description", with: "Capybara salary"
    click_button "Create Transaction"

    expect(page).to have_content(I18n.t("notices.transactions.created"))
    expect(page).to have_content("Capybara salary")

    transaction = user.transactions.find_by!(description: "Capybara salary")

    visit "/transactions/#{transaction.id}/edit"
    fill_in "Description", with: "Capybara salary updated"
    click_button "Update Transaction"

    expect(page).to have_content(I18n.t("notices.transactions.updated"))
    expect(page).to have_content("Capybara salary updated")
  end
end
