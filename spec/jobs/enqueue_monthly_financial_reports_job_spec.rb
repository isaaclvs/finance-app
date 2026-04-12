require "rails_helper"

RSpec.describe EnqueueMonthlyFinancialReportsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it "enqueues monthly report job for each user" do
    user_one = create(:user)
    user_two = create(:user)
    reference_month = "2026-03-01"

    expect {
      described_class.perform_now(reference_month)
    }.to have_enqueued_job(MonthlyFinancialReportJob).with(user_one.id, reference_month)
      .and have_enqueued_job(MonthlyFinancialReportJob).with(user_two.id, reference_month)
  end
end
