module Dashboard
  class TransactionsFilter
    def initialize(scope:, params:)
      @scope = scope
      @params = params
    end

    def call(include_date_filter: true)
      scoped = @scope
      scoped = scoped.by_type(@params[:transaction_type]) if @params[:transaction_type].present?
      scoped = scoped.by_category(@params[:category_id]) if @params[:category_id].present?
      scoped = scoped.by_tag(@params[:tag_id]) if @params[:tag_id].present?
      scoped = scoped.search_description(@params[:search]) if @params[:search].present?
      return scoped unless include_date_filter

      apply_period_filter(scoped)
    end

    private

    def apply_period_filter(scope)
      case @params[:period]
      when "today"
        scope.where(date: Date.current)
      when "week"
        scope.where(date: Date.current.beginning_of_week..Date.current.end_of_week)
      when "month"
        scope.by_month(Date.current)
      when "custom"
        custom_date_range_scope(scope)
      else
        scope
      end
    end

    def custom_date_range_scope(scope)
      return scope unless @params[:start_date].present? && @params[:end_date].present?

      scope.by_date_range(@params[:start_date], @params[:end_date])
    end
  end
end
