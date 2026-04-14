class DashboardController < ApplicationController
  before_action :load_categories
  before_action :load_tags
  helper_method :charts_cache_key

  def index
    @user = Current.user
    @transactions = filtered_transactions
    @export_transactions = filtered_chart_transactions.ordered
    @budget_alerts = Dashboard::CategoryBudgetAlerts.new(
      scope: budget_alert_transactions,
      categories: budget_alert_categories
    ).call

    # Goals data
    @goals = Current.user.goals.includes(:category).ordered
    @recent_goals = @goals.limit(3)
    @goals_stats = {
      total: @goals.count,
      active: @goals.active_goals.count,
      completed: @goals.completed_goals.count,
      overdue: @goals.overdue.count
    }

    charts_data = Dashboard::ChartsData.new(scope: filtered_chart_transactions).call
    @income_vs_expenses_data = charts_data[:income_vs_expenses]
    @expenses_by_category_data = charts_data[:expenses_by_category]
    @monthly_evolution_data = Dashboard::MonthlyEvolutionData.new(scope: unbounded_chart_transactions).call
    @month_comparison = Dashboard::MonthComparisonData.new(scope: @user.transactions).call

    respond_to do |format|
      format.html
      format.csv do
        send_data(
          Export::TransactionsCsv.new(transactions: @export_transactions).call,
          filename: export_filename,
          type: "text/csv; charset=utf-8"
        )
      end
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("charts_and_transactions",
            partial: "dashboard/charts_and_transactions")
        ]
      end
    end
  end

  private

  def filtered_transactions
    @filtered_transactions ||= filtered_chart_transactions.includes(:category, :tags).ordered.page(params[:page]).per(20)
  end

  def filtered_chart_transactions
    @filtered_chart_transactions ||= transactions_filter.call(include_date_filter: true)
  end

  def budget_alert_transactions
    return @user.transactions.by_month(Date.current) if params[:period].blank?

    filtered_chart_transactions
  end

  def budget_alert_categories
    scoped_categories = @categories
    return scoped_categories unless params[:category_id].present?

    scoped_categories.where(id: params[:category_id])
  end

  def unbounded_chart_transactions
    @unbounded_chart_transactions ||= transactions_filter.call(include_date_filter: false)
  end

  def transactions_filter
    @transactions_filter ||= Dashboard::TransactionsFilter.new(scope: @user.transactions, params: params)
  end

  def load_categories
    @categories = Current.user.categories.ordered
  end

  def load_tags
    @tags = Current.user.tags.ordered
  end

  def export_filename
    "transactions-#{Date.current}.csv"
  end

  def charts_cache_key
    [
      "dashboard/charts",
      @user.id,
      filter_cache_params,
      filtered_chart_transactions.maximum(:updated_at)&.to_i
    ]
  end

  def filter_cache_params
    params.slice("transaction_type", "category_id", "tag_id", "search", "period", "start_date", "end_date").to_unsafe_h
  end
end
