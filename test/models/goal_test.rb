require "test_helper"

class GoalTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @category = categories(:one)
  end

  test "should be valid" do
    goal = Goal.new(
      title: "Emergency Fund",
      target_amount: 10000,
      current_amount: 0,
      target_date: 1.year.from_now,
      goal_type: "savings",
      status: "active",
      user: @user
    )
    assert goal.valid?
  end

  test "should require title" do
    goal = Goal.new(target_amount: 1000, target_date: 1.year.from_now, goal_type: "savings", user: @user)
    assert_not goal.valid?
    assert_includes goal.errors[:title], "can't be blank"
  end

  test "should require target_amount" do
    goal = Goal.new(title: "Test", target_date: 1.year.from_now, goal_type: "savings", user: @user)
    assert_not goal.valid?
    assert_includes goal.errors[:target_amount], "is not a number"
  end

  test "should require positive target_amount" do
    goal = Goal.new(
      title: "Test",
      target_amount: -100,
      target_date: 1.year.from_now,
      goal_type: "savings",
      user: @user
    )
    assert_not goal.valid?
    assert_includes goal.errors[:target_amount], "must be greater than 0"
  end

  test "should require target_date" do
    goal = Goal.new(title: "Test", target_amount: 1000, goal_type: "savings", user: @user)
    assert_not goal.valid?
    assert_includes goal.errors[:target_date], "can't be blank"
  end

  test "should not allow past target_date on create" do
    goal = Goal.new(
      title: "Test",
      target_amount: 1000,
      target_date: 1.day.ago,
      goal_type: "savings",
      user: @user
    )
    assert_not goal.valid?
    assert_includes goal.errors[:target_date], "can't be in the past"
  end

  test "should allow today as target_date" do
    goal = Goal.new(
      title: "Test",
      target_amount: 1000,
      target_date: Date.current,
      goal_type: "savings",
      user: @user
    )
    assert goal.valid?
  end

  test "should not allow current_amount greater than target_amount" do
    goal = Goal.new(
      title: "Test",
      target_amount: 1000,
      current_amount: 1500,
      target_date: 1.year.from_now,
      goal_type: "savings",
      user: @user
    )
    assert_not goal.valid?
    assert_includes goal.errors[:current_amount], "can't be greater than target amount"
  end

  test "should calculate progress percentage" do
    goal = goals(:one)  # target: 10000, current: 2500
    assert_equal 25.0, goal.progress_percentage
  end

  test "should calculate remaining amount" do
    goal = goals(:one)  # target: 10000, current: 2500
    assert_equal 7500.0, goal.remaining_amount
  end

  test "should detect overdue goals" do
    goal = goals(:one)
    goal.update_column(:target_date, 1.month.ago)  # Bypass validation
    goal.reload
    assert goal.overdue?
  end

  test "should detect completed goals by status" do
    goal = goals(:two)  # status: completed
    assert goal.completed?
  end

  test "should detect completed goals by amount" do
    goal = goals(:one)
    goal.update!(current_amount: goal.target_amount)
    assert goal.completed?
  end

  test "should update progress" do
    goal = goals(:one)
    initial_amount = goal.current_amount

    assert goal.update_progress(5000)
    goal.reload
    assert_equal 5000, goal.current_amount
  end

  test "should add progress" do
    goal = goals(:one)
    initial_amount = goal.current_amount

    assert goal.add_progress(1000)
    goal.reload
    assert_equal initial_amount + 1000, goal.current_amount
  end

  test "should subtract progress" do
    goal = goals(:one)
    initial_amount = goal.current_amount

    assert goal.subtract_progress(500)
    goal.reload
    assert_equal initial_amount - 500, goal.current_amount
  end

  test "should mark as completed when target reached" do
    goal = goals(:one)
    goal.update_progress(goal.target_amount)
    goal.reload
    assert_equal "completed", goal.status
  end

  test "should return correct goal type colors" do
    assert_equal "emerald", Goal.new(goal_type: "savings").goal_type_color
    assert_equal "red", Goal.new(goal_type: "expense_reduction").goal_type_color
    assert_equal "blue", Goal.new(goal_type: "income_increase").goal_type_color
    assert_equal "purple", Goal.new(goal_type: "debt_payoff").goal_type_color
  end

  test "should return correct status colors" do
    assert_equal "blue", Goal.new(status: "active").status_color
    assert_equal "green", Goal.new(status: "completed").status_color
    assert_equal "yellow", Goal.new(status: "paused").status_color
    assert_equal "gray", Goal.new(status: "cancelled").status_color
  end

  test "active_goals scope should return active goals" do
    active_goals = Goal.active_goals
    active_goals.each do |goal|
      assert_equal "active", goal.status
    end
  end

  test "completed_goals scope should return completed goals" do
    completed_goals = Goal.completed_goals
    completed_goals.each do |goal|
      assert_equal "completed", goal.status
    end
  end

  test "should belong to user" do
    goal = goals(:one)
    assert_equal users(:one), goal.user
  end

  test "should optionally belong to category" do
    goal = goals(:one)
    assert_equal categories(:one), goal.category

    # Should allow nil category
    goal.category = nil
    assert goal.valid?
  end
end
