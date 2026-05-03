namespace :goals do
  desc "Process monthly rollover for recurring goals"
  task process_rollovers: :environment do
    ProcessGoalRolloversJob.perform_now
  end
end
