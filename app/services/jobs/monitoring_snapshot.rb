module Jobs
  class MonitoringSnapshot
    def call
      return default_snapshot unless solid_queue_available?

      {
        pending: SolidQueue::ReadyExecution.count + SolidQueue::ScheduledExecution.count,
        running: SolidQueue::ClaimedExecution.count,
        failed: SolidQueue::FailedExecution.count,
        finished: SolidQueue::Job.where.not(finished_at: nil).count
      }
    rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError
      default_snapshot
    end

    private

    def solid_queue_available?
      defined?(SolidQueue::Job) &&
        defined?(SolidQueue::ReadyExecution) &&
        defined?(SolidQueue::ScheduledExecution) &&
        defined?(SolidQueue::ClaimedExecution) &&
        defined?(SolidQueue::FailedExecution)
    end

    def default_snapshot
      {
        pending: 0,
        running: 0,
        failed: 0,
        finished: 0
      }
    end
  end
end
