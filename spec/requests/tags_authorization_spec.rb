require "rails_helper"

RSpec.describe "Tags authorization", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:own_tag) { create(:tag, user: user, name: "Own") }
  let!(:other_tag) { create(:tag, user: other_user, name: "Other") }

  it "redirects unauthenticated access to tags index" do
    get "/tags"

    expect(response).to redirect_to(new_user_session_path)
  end

  it "returns not found when editing another user's tag" do
    sign_in_user(user)

    get "/tags/#{other_tag.id}/edit"

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found when updating another user's tag" do
    sign_in_user(user)

    patch "/tags/#{other_tag.id}", params: { tag: { name: "Hacked" } }

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found when deleting another user's tag" do
    sign_in_user(user)

    delete "/tags/#{other_tag.id}"

    expect(response).to have_http_status(:not_found)
  end

  it "allows managing own tag" do
    sign_in_user(user)

    patch "/tags/#{own_tag.id}", params: { tag: { name: "Updated" } }

    expect(response).to redirect_to(tags_path)
    expect(own_tag.reload.name).to eq("Updated")
  end
end