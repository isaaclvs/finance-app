require "rails_helper"

RSpec.describe "Jobs monitoring", type: :request do
  let(:user) { create(:user) }

  it "redirects unauthenticated users" do
    get "/jobs/monitoring"

    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders snapshot for authenticated users" do
    sign_in user
    allow_any_instance_of(Jobs::MonitoringSnapshot).to receive(:call).and_return(
      pending: 3,
      running: 1,
      failed: 0,
      finished: 12
    )

    get "/jobs/monitoring"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Jobs Monitoring")
    expect(response.body).to include("Pending")
    expect(response.body).to include("Running")
    expect(response.body).to include("Finished")
  end
end
