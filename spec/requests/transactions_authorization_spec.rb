require "rails_helper"

RSpec.describe "Transactions authorization", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:user_category) { create(:category, user: user) }
  let(:other_category) { create(:category, user: other_user) }
  let!(:own_transaction) { create(:transaction, user: user, category: user_category, description: "Own tx") }
  let!(:other_transaction) { create(:transaction, user: other_user, category: other_category, description: "Other tx") }

  it "redirects unauthenticated access to transactions index" do
    get "/transactions"

    expect(response).to redirect_to(new_user_session_path)
  end

  it "returns not found when accessing another user's transaction" do
    sign_in_user(user)

    get "/transactions/#{other_transaction.id}"

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found when updating another user's transaction" do
    sign_in_user(user)

    patch "/transactions/#{other_transaction.id}", params: {
      transaction: {
        description: "Attempted update"
      }
    }

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found when deleting another user's transaction" do
    sign_in_user(user)

    delete "/transactions/#{other_transaction.id}"

    expect(response).to have_http_status(:not_found)
  end

  it "allows access to edit own transaction" do
    sign_in_user(user)

    get "/transactions/#{own_transaction.id}/edit"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Edit")
  end
end
