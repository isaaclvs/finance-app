require "rails_helper"

RSpec.describe "Transactions pagination", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user, name: "General") }

  before do
    sign_in_user(user)

    25.times do |i|
      create(
        :transaction,
        :income,
        user: user,
        category: category,
        description: format("Transaction %02d", i + 1),
        amount: 10 + i,
        date: Date.current
      )
    end
  end

  it "shows 20 transactions on first page and remaining on second page" do
    get "/transactions"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Transaction 25")
    expect(response.body).not_to include("Transaction 01")

    get "/transactions", params: { page: 2 }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Transaction 01")
    expect(response.body).not_to include("Transaction 25")
  end
end
