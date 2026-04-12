class EnqueueMonthlyFinancialReportsJob < ApplicationJob
  queue_as :reports

  def perform(reference_month = Date.current.prev_month.iso8601)
    User.find_each do |user|
      MonthlyFinancialReportJob.perform_later(user.id, reference_month)
    end
  end
end
