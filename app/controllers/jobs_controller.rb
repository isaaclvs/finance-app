class JobsController < ApplicationController
  def monitoring
    @snapshot = Jobs::MonitoringSnapshot.new.call
  end
end
