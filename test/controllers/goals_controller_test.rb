require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = categories(:one)
    @goal = goals(:one)
    sign_in @user
  end

  test "should get index" do
    get goals_url
    assert_response :success
  end

  test "should get new" do
    get new_goal_url
    assert_response :success
  end

  test "should create goal" do
    assert_difference("Goal.count") do
      post goals_url, params: { goal: {
        title: "Test Goal",
        description: "Test description",
        target_amount: 1000,
        current_amount: 0,
        target_date: 1.year.from_now,
        goal_type: "savings",
        status: "active",
        category_id: @category.id
      } }
    end

    assert_redirected_to goals_path
  end

  test "should show goal" do
    get goal_url(@goal)
    assert_response :success
  end

  test "should get edit" do
    get edit_goal_url(@goal)
    assert_response :success
  end

  test "should update goal" do
    patch goal_url(@goal), params: { goal: { title: "Updated Goal" } }
    assert_redirected_to goal_path(@goal)
    @goal.reload
    assert_equal "Updated Goal", @goal.title
  end

  test "should update progress" do
    patch update_progress_goal_url(@goal), params: { amount: 500 }
    assert_redirected_to goal_path(@goal)
    @goal.reload
    assert_equal 500, @goal.current_amount
  end

  test "should destroy goal" do
    assert_difference("Goal.count", -1) do
      delete goal_url(@goal)
    end

    assert_redirected_to goals_path
  end

  test "should filter goals by status" do
    get goals_url, params: { status: "active" }
    assert_response :success
  end

  test "should filter goals by type" do
    get goals_url, params: { goal_type: "savings" }
    assert_response :success
  end

  test "should search goals" do
    get goals_url, params: { search: "Emergency" }
    assert_response :success
  end
end
