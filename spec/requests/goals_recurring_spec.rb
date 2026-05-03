require "rails_helper"

RSpec.describe "Goals recurring filtering", type: :request do
  let(:user) { create(:user) }

  before { sign_in_user(user) }

  describe "GET /goals" do
    let!(:active_goal) { create(:goal, user: user, title: "Active Savings Goal") }
    let!(:rolled_over_goal) do
      g = build(:goal, :rolled_over, user: user, title: "Old Rolled Over Goal")
      g.save!(validate: false)
      g
    end

    it "excludes rolled_over goals by default" do
      get "/goals"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(active_goal.title)
      expect(response.body).not_to include(rolled_over_goal.title)
    end

    it "shows only rolled_over goals with ?history=true" do
      get "/goals", params: { history: "true" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rolled_over_goal.title)
      expect(response.body).not_to include(active_goal.title)
    end

    it "ignores status filter when showing history" do
      get "/goals", params: { history: "true", status: "active" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rolled_over_goal.title)
    end

    it "applies status filter normally without history param" do
      paused_goal = create(:goal, user: user, title: "Paused Goal", status: "paused")

      get "/goals", params: { status: "paused" }

      expect(response.body).to include(paused_goal.title)
      expect(response.body).not_to include(active_goal.title)
    end
  end

  describe "POST /goals with recurring" do
    let(:category) { create(:category, user: user) }

    it "creates a recurring goal and sets period dates automatically" do
      target_date = 1.month.from_now.end_of_month.to_date

      post "/goals", params: {
        goal: {
          title: "Monthly Savings",
          goal_type: "savings",
          target_amount: 500,
          current_amount: 0,
          target_date: target_date,
          recurring: true,
          category_id: category.id
        }
      }

      goal = Goal.last
      expect(goal.recurring).to be true
      expect(goal.period_start).to eq(target_date.beginning_of_month)
      expect(goal.period_end).to eq(target_date.end_of_month)
    end
  end
end
