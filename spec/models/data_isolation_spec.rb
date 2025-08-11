require 'rails_helper'

RSpec.describe "Data isolation between users", type: :model do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:category1) { create(:category, user: user1) }
  let(:category2) { create(:category, user: user2) }

  it "users only see their own transactions" do
    transaction1 = create(:transaction, user: user1, category: category1)
    transaction2 = create(:transaction, user: user2, category: category2)
    
    expect(user1.transactions).to include(transaction1)
    expect(user1.transactions).not_to include(transaction2)
    expect(user2.transactions).to include(transaction2)
    expect(user2.transactions).not_to include(transaction1)
  end

  it "users only see their own categories" do
    expect(user1.categories).to include(category1)
    expect(user1.categories).not_to include(category2)
    expect(user2.categories).to include(category2)
    expect(user2.categories).not_to include(category1)
  end

  it "users only see their own goals" do
    goal1 = create(:goal, user: user1, category: category1)
    goal2 = create(:goal, user: user2, category: category2)
    
    expect(user1.goals).to include(goal1)
    expect(user1.goals).not_to include(goal2)
    expect(user2.goals).to include(goal2)
    expect(user2.goals).not_to include(goal1)
  end
end