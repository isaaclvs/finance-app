require "rails_helper"

RSpec.describe "Authentication flow", type: :feature do
  let!(:user) { create(:user, email: "capybara@example.com", password: "password123", password_confirmation: "password123") }

  it "signs in and signs out successfully" do
    visit "/users/sign_in"

    expect(page).to have_selector("input#user_email")

    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password123"
    click_button "Sign in"

    expect(page).to have_current_path("/transactions", ignore_query: true)
    expect(page).to have_content("Signed in successfully")

    click_button "Sign out", match: :first

    expect(page).to have_current_path("/users/sign_in", ignore_query: true)
    expect(page).to have_content("Signed out successfully")
  end
end
