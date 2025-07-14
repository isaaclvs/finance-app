require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should redirect logged in user to transactions" do
    sign_in users(:one)
    get root_url
    assert_redirected_to transactions_path
  end

  test "should redirect logged out user to sign in" do
    get root_url
    assert_redirected_to new_user_session_path
  end
end
