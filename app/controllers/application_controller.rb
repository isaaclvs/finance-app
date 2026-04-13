class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern unless Rails.env.test?

  before_action :authenticate_user!
  around_action :log_request_performance, if: :performance_logging_enabled?

  private

  def performance_logging_enabled?
    Rails.env.development? && %w[dashboard transactions].include?(controller_name)
  end

  def log_request_performance
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    query_count = 0

    callback = lambda do |_name, _started, _finished, _id, payload|
      query_count += 1 if payload[:sql] !~ /SCHEMA/ && !payload[:cached]
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      yield
    end

    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round(2)

    Rails.logger.info(
      "[perf] controller=#{controller_name} action=#{action_name} path=#{request.path} " \
      "status=#{response.status} duration_ms=#{duration_ms} queries=#{query_count}"
    )
  end
end
