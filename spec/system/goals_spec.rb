require 'rails_helper'

RSpec.describe 'Goals', type: :system do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }

  before do
    sign_in user
  end

  describe 'Goals index' do
    context 'when user has no goals' do
      it 'displays empty state with create button' do
        visit goals_path

        expect(page).to have_content('No goals yet')
        expect(page).to have_content('Start tracking your financial objectives')
        expect(page).to have_link('Create Your First Goal')
      end
    end

    context 'when user has goals' do
      let!(:active_goal) { create(:goal, user: user, category: category, title: 'Emergency Fund') }
      let!(:completed_goal) { create(:goal, :completed, user: user, title: 'Vacation Fund') }
      let!(:overdue_goal) { create(:goal, :overdue, user: user, title: 'Car Fund') }

      it 'displays all goals with their information' do
        visit goals_path

        expect(page).to have_content('Emergency Fund')
        expect(page).to have_content('Vacation Fund')
        expect(page).to have_content('Car Fund')

        # Check for goal type badges
        expect(page).to have_content('Savings')

        # Check for status badges
        expect(page).to have_content('Active')
        expect(page).to have_content('Completed')
      end

      it 'allows filtering goals by status' do
        visit goals_path

        select 'Active', from: 'status'

        expect(page).to have_content('Emergency Fund')
        expect(page).to have_content('Car Fund')
        expect(page).not_to have_content('Vacation Fund')
      end

      it 'allows filtering goals by type' do
        create(:goal, :expense_reduction, user: user, title: 'Reduce Spending')

        visit goals_path

        select 'Expense Reduction', from: 'goal_type'

        expect(page).to have_content('Reduce Spending')
        expect(page).not_to have_content('Emergency Fund')
      end

      it 'allows searching goals by title' do
        visit goals_path

        fill_in 'search', with: 'Emergency'

        expect(page).to have_content('Emergency Fund')
        expect(page).not_to have_content('Vacation Fund')
        expect(page).not_to have_content('Car Fund')
      end
    end
  end

  describe 'Creating a goal' do
    it 'creates a new goal successfully' do
      visit goals_path
      click_link 'Add Goal'

      fill_in 'Title', with: 'New Emergency Fund'
      fill_in 'Description', with: 'Save money for emergencies'
      select 'Savings', from: 'Goal type'
      fill_in 'Target amount', with: '10000'
      fill_in 'Current amount', with: '1000'
      fill_in 'Target date', with: 1.year.from_now.strftime('%Y-%m-%d')
      select category.name, from: 'Category (Optional)'

      click_button 'Create Goal'

      expect(page).to have_content('Goal created successfully')
      expect(page).to have_content('New Emergency Fund')
      expect(page).to have_content('$1,000')
      expect(page).to have_content('$10,000')
    end

    it 'shows validation errors for invalid goal' do
      visit goals_path
      click_link 'Add Goal'

      fill_in 'Title', with: ''
      fill_in 'Target amount', with: '-100'

      click_button 'Create Goal'

      expect(page).to have_content('can\'t be blank')
      expect(page).to have_content('must be greater than 0')
    end

    it 'prevents creating goals with past target dates' do
      visit goals_path
      click_link 'Add Goal'

      fill_in 'Title', with: 'Test Goal'
      fill_in 'Target amount', with: '1000'
      fill_in 'Target date', with: 1.day.ago.strftime('%Y-%m-%d')
      select 'Savings', from: 'Goal type'

      click_button 'Create Goal'

      expect(page).to have_content('can\'t be in the past')
    end
  end

  describe 'Viewing a goal' do
    let!(:goal) { create(:goal, user: user, category: category, current_amount: 2500, target_amount: 10000) }

    it 'displays goal details' do
      visit goal_path(goal)

      expect(page).to have_content(goal.title)
      expect(page).to have_content(goal.description)
      expect(page).to have_content('$2,500')
      expect(page).to have_content('$10,000')
      expect(page).to have_content('$7,500') # remaining amount
      expect(page).to have_content('25%') # progress percentage
      expect(page).to have_content(goal.target_date.strftime('%B %d, %Y'))
    end

    it 'shows goal type and status badges' do
      visit goal_path(goal)

      expect(page).to have_content(goal.goal_type.humanize)
      expect(page).to have_content(goal.status.humanize)
    end

    it 'displays category information when present' do
      visit goal_path(goal)

      expect(page).to have_content(category.name)
    end
  end

  describe 'Editing a goal' do
    let!(:goal) { create(:goal, user: user, category: category) }

    it 'updates goal successfully' do
      visit goal_path(goal)
      click_link 'Edit Goal'

      fill_in 'Title', with: 'Updated Goal Title'
      fill_in 'Target amount', with: '15000'

      click_button 'Update Goal'

      expect(page).to have_content('Goal updated successfully')
      expect(page).to have_content('Updated Goal Title')
      expect(page).to have_content('$15,000')
    end
  end

  describe 'Updating goal progress', js: true do
    let!(:goal) { create(:goal, user: user, current_amount: 1000, target_amount: 10000) }

    it 'updates progress successfully' do
      visit goals_path

      # Click update progress button
      within("##{dom_id(goal)}") do
        click_button 'Update Progress'
      end

      # Fill in new amount in modal
      within("#update_progress_modal_#{goal.id}") do
        fill_in 'goal[amount]', with: '2500'
        click_button 'Update Progress'
      end

      expect(page).to have_content('Goal progress updated successfully')

      # Check that the progress bar and amounts are updated
      expect(page).to have_content('$2,500')
      expect(page).to have_content('25%')
    end

    it 'marks goal as completed when target is reached' do
      visit goals_path

      within("##{dom_id(goal)}") do
        click_button 'Update Progress'
      end

      within("#update_progress_modal_#{goal.id}") do
        fill_in 'goal[amount]', with: '10000'
        click_button 'Update Progress'
      end

      expect(page).to have_content('Goal completed!')
      expect(page).to have_content('Completed')
    end
  end

  describe 'Deleting a goal' do
    let!(:goal) { create(:goal, user: user, category: category) }

    it 'deletes goal successfully' do
      visit goal_path(goal)

      accept_confirm do
        click_link 'Delete Goal'
      end

      expect(page).to have_content('Goal deleted successfully')
      expect(page).not_to have_content(goal.title)
    end
  end

  describe 'Dashboard integration' do
    let!(:active_goal) { create(:goal, user: user, title: 'Emergency Fund') }
    let!(:completed_goal) { create(:goal, :completed, user: user, title: 'Vacation') }
    let!(:overdue_goal) { create(:goal, :overdue, user: user, title: 'Car Fund') }

    it 'displays goals summary on dashboard' do
      visit dashboard_path

      expect(page).to have_content('Goals Overview')
      expect(page).to have_content('3') # Total goals
      expect(page).to have_content('2') # Active goals (active + overdue)
      expect(page).to have_content('1') # Completed goals
      expect(page).to have_content('1') # Overdue goals

      # Should show recent goals
      expect(page).to have_content('Emergency Fund')
      expect(page).to have_content('Vacation')
      expect(page).to have_content('Car Fund')
    end

    it 'shows empty state when no goals exist' do
      visit dashboard_path

      expect(page).to have_content('No Goals Yet')
      expect(page).to have_link('Create Your First Goal')
    end

    it 'provides navigation to goals section' do
      visit dashboard_path

      click_link 'View All Goals'

      expect(page).to have_current_path(goals_path)
    end
  end

  describe 'Responsive design' do
    let!(:goal) { create(:goal, user: user, category: category) }

    it 'works on mobile viewport' do
      resize_window_to_mobile

      visit goals_path

      expect(page).to have_content(goal.title)
      expect(page).to have_button('Update Progress')
    end
  end

  private

  def resize_window_to_mobile
    current_window.resize_to(375, 667) # iPhone dimensions
  end
end
