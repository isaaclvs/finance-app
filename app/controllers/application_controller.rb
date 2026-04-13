class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern unless Rails.env.test?

  before_action :set_locale
  before_action :authenticate_user!
  around_action :log_request_performance, if: :performance_logging_enabled?

  private
    def set_locale
      I18n.locale = extract_locale_from_header || I18n.default_locale
    end

    def extract_locale_from_header
      header = request.env["HTTP_ACCEPT_LANGUAGE"].to_s

      locales = header.scan(/[A-Za-z-]+/).map(&:downcase)
      return :"pt-BR" if locales.any? { |locale| locale == "pt-br" || locale.start_with?("pt") }
      return :en if locales.any? { |locale| locale.start_with?("en") }

      nil
    end

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
