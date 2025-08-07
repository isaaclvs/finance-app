require 'rails_helper'

RSpec.describe GoalsController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let(:goal) { create(:goal, user: user, category: category) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let!(:goals) { create_list(:goal, 3, user: user) }

    it 'assigns user goals to @goals' do
      get :index
      expect(assigns(:goals)).to match_array(user.goals.ordered)
    end

    it 'responds successfully' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    context 'with filters' do
      let!(:active_goal) { create(:goal, user: user, status: 'active') }
      let!(:completed_goal) { create(:goal, user: user, status: 'completed') }

      it 'filters by status' do
        get :index, params: { status: 'active' }
        expect(assigns(:goals)).to include(active_goal)
        expect(assigns(:goals)).not_to include(completed_goal)
      end

      it 'filters by goal_type' do
        savings_goal = create(:goal, user: user, goal_type: 'savings')
        debt_goal = create(:goal, user: user, goal_type: 'debt_payoff')

        get :index, params: { goal_type: 'savings' }
        expect(assigns(:goals)).to include(savings_goal)
        expect(assigns(:goals)).not_to include(debt_goal)
      end

      it 'filters by search term' do
        matching_goal = create(:goal, user: user, title: 'Emergency Fund')
        non_matching_goal = create(:goal, user: user, title: 'Vacation')

        get :index, params: { search: 'Emergency' }
        expect(assigns(:goals)).to include(matching_goal)
        expect(assigns(:goals)).not_to include(non_matching_goal)
      end
    end
  end

  describe 'GET #show' do
    it 'assigns the requested goal to @goal' do
      get :show, params: { id: goal.id }
      expect(assigns(:goal)).to eq(goal)
    end

    it 'responds successfully' do
      get :show, params: { id: goal.id }
      expect(response).to have_http_status(:ok)
    end

    it 'renders the show template' do
      get :show, params: { id: goal.id }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'assigns a new goal to @goal' do
      get :new
      expect(assigns(:goal)).to be_a_new(Goal)
      expect(assigns(:goal).user).to eq(user)
    end

    it 'assigns categories to @categories' do
      categories = create_list(:category, 2, user: user)
      get :new
      expect(assigns(:categories)).to match_array(categories)
    end

    it 'responds successfully' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested goal to @goal' do
      get :edit, params: { id: goal.id }
      expect(assigns(:goal)).to eq(goal)
    end

    it 'assigns categories to @categories' do
      categories = create_list(:category, 2, user: user)
      get :edit, params: { id: goal.id }
      expect(assigns(:categories)).to match_array(categories)
    end

    it 'responds successfully' do
      get :edit, params: { id: goal.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        title: 'Emergency Fund',
        description: 'Save for emergencies',
        target_amount: 5000,
        current_amount: 0,
        target_date: 1.year.from_now,
        goal_type: 'savings',
        status: 'active',
        category_id: category.id
      }
    end

    context 'with valid parameters' do
      it 'creates a new goal' do
        expect {
          post :create, params: { goal: valid_attributes }
        }.to change(Goal, :count).by(1)
      end

      it 'assigns the goal to the current user' do
        post :create, params: { goal: valid_attributes }
        expect(assigns(:goal).user).to eq(user)
      end

      it 'redirects to goals index' do
        post :create, params: { goal: valid_attributes }
        expect(response).to redirect_to(goals_path)
      end

      it 'sets a success flash message' do
        post :create, params: { goal: valid_attributes }
        expect(flash[:notice]).to eq('Goal created successfully')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { title: '', target_amount: -100 } }

      it 'does not create a new goal' do
        expect {
          post :create, params: { goal: invalid_attributes }
        }.not_to change(Goal, :count)
      end

      it 'renders the new template' do
        post :create, params: { goal: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { title: 'Updated Goal Title', target_amount: 10000 } }

    context 'with valid parameters' do
      it 'updates the requested goal' do
        patch :update, params: { id: goal.id, goal: new_attributes }
        goal.reload
        expect(goal.title).to eq('Updated Goal Title')
        expect(goal.target_amount).to eq(10000)
      end

      it 'redirects to the goal' do
        patch :update, params: { id: goal.id, goal: new_attributes }
        expect(response).to redirect_to(goal_path(goal))
      end

      it 'sets a success flash message' do
        patch :update, params: { id: goal.id, goal: new_attributes }
        expect(flash[:notice]).to eq('Goal updated successfully')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { title: '', target_amount: -100 } }

      it 'does not update the goal' do
        old_title = goal.title
        patch :update, params: { id: goal.id, goal: invalid_attributes }
        goal.reload
        expect(goal.title).to eq(old_title)
      end

      it 'renders the edit template' do
        patch :update, params: { id: goal.id, goal: invalid_attributes }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested goal' do
      goal_to_delete = create(:goal, user: user)
      expect {
        delete :destroy, params: { id: goal_to_delete.id }
      }.to change(Goal, :count).by(-1)
    end

    it 'redirects to goals index' do
      delete :destroy, params: { id: goal.id }
      expect(response).to redirect_to(goals_path)
    end

    it 'sets a success flash message' do
      delete :destroy, params: { id: goal.id }
      expect(flash[:notice]).to eq('Goal deleted successfully')
    end
  end

  describe 'PATCH #update_progress' do
    context 'with valid amount' do
      it 'updates the goal progress' do
        patch :update_progress, params: { id: goal.id, amount: 500 }
        goal.reload
        expect(goal.current_amount).to eq(500)
      end

      it 'redirects to the goal' do
        patch :update_progress, params: { id: goal.id, amount: 500 }
        expect(response).to redirect_to(goal_path(goal))
      end

      it 'sets a success flash message' do
        patch :update_progress, params: { id: goal.id, amount: 500 }
        expect(flash[:notice]).to eq('Goal progress updated successfully')
      end

      it 'marks goal as completed when target is reached' do
        patch :update_progress, params: { id: goal.id, amount: goal.target_amount }
        goal.reload
        expect(goal.status).to eq('completed')
      end
    end

    context 'with invalid amount' do
      it 'handles non-numeric amounts gracefully' do
        patch :update_progress, params: { id: goal.id, amount: 'invalid' }
        goal.reload
        expect(goal.current_amount).to eq(0)
      end
    end
  end

  describe 'authorization' do
    let(:other_user) { create(:user) }
    let(:other_goal) { create(:goal, user: other_user) }

    before do
      sign_in user
    end

    it 'prevents accessing other users goals' do
      expect {
        get :show, params: { id: other_goal.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'prevents updating other users goals' do
      expect {
        patch :update, params: { id: other_goal.id, goal: { title: 'Hacked' } }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'prevents deleting other users goals' do
      expect {
        delete :destroy, params: { id: other_goal.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
