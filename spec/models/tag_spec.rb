require "rails_helper"

RSpec.describe Tag, type: :model do
  let(:user) { create(:user) }

  it "is valid with valid attributes" do
    tag = build(:tag, user: user)

    expect(tag).to be_valid
  end

  it "requires unique name scoped to user" do
    create(:tag, user: user, name: "Work")
    duplicate = build(:tag, user: user, name: "Work")

    expect(duplicate).not_to be_valid
  end

  it "allows same tag name for different users" do
    create(:tag, name: "Work")
    other_user_tag = build(:tag, user: create(:user), name: "Work")

    expect(other_user_tag).to be_valid
  end
end