module AuthHelpers
  def sign_in_user(user = nil)
    user ||= create(:user)
    Current.user = user
    user
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
