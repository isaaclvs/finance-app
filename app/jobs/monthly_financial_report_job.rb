class MonthlyFinancialReportJob < ApplicationJob
  queue_as :reports

  def perform(user_id, reference_month = Date.current.prev_month.iso8601)
    user = User.find_by(id: user_id)
    return unless user

    reference_date = parse_reference_month(reference_month)
    summary = Reports::MonthlySummary.new(user: user, reference_date: reference_date).call

    ReportsMailer.monthly_summary(user, summary).deliver_now
  end

  private

  def parse_reference_month(reference_month)
    Date.parse(reference_month.to_s).beginning_of_month
  rescue Date::Error
    Date.current.prev_month.beginning_of_month
  end
end
