# frozen_string_literal: true

if defined?(Bullet)
  Rails.application.configure do
    config.after_initialize do
      bullet_in_test = Rails.env.test? && ENV["ENABLE_BULLET_IN_TEST"] == "1"
      Bullet.enable = Rails.env.development? || bullet_in_test

      next unless Bullet.enable?

      Bullet.rails_logger = true
      Bullet.bullet_logger = true
      Bullet.console = true if Rails.env.development?
      Bullet.add_footer = true if Rails.env.development?
      Bullet.raise = true if bullet_in_test
    end
  end
end
