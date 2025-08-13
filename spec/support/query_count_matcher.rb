# Custom matcher to test for N+1 query problems
RSpec::Matchers.define :exceed_query_limit do |expected|
  match do |block|
    query_count = 0
    callback = lambda do |name, started, finished, unique_id, data|
      query_count += 1 if data[:sql] !~ /SCHEMA/
    end

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &block)

    @actual_count = query_count
    @actual_count > expected
  end

  failure_message do |block|
    "Expected query count to not exceed #{expected}, but got #{@actual_count} queries"
  end

  failure_message_when_negated do |block|
    "Expected query count to exceed #{expected}, but got #{@actual_count} queries"
  end

  description do
    "execute more than #{expected} database queries"
  end
end

# Usage: expect { some_code }.not_to exceed_query_limit(3)
