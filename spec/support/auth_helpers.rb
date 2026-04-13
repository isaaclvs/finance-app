module AuthHelpers
  def sign_in_user(user = nil)
    user ||= create(:user)

    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }

    user
  end

  def sign_out_user
    delete destroy_user_session_path
  rescue StandardError
    # No-op helper for specs that do not establish a session.
    nil
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
