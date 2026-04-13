class DashboardController < ApplicationController
  before_action :load_categories
  helper_method :charts_cache_key

  def index
    @user = Current.user
    @transactions = filtered_transactions
    @export_transactions = chart_transactions.ordered

    # Goals data
    @goals = Current.user.goals.includes(:category).ordered
    @recent_goals = @goals.limit(3)
    @goals_stats = {
      total: @goals.count,
      active: @goals.active_goals.count,
      completed: @goals.completed_goals.count,
      overdue: @goals.overdue.count
    }

    @income_vs_expenses_data = income_vs_expenses_chart_data
    @expenses_by_category_data = expenses_by_category_chart_data
    @monthly_evolution_data = monthly_evolution_chart_data

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
    @filtered_transactions ||= apply_filters(@user.transactions.includes(:category), include_date_filter: true)
                               .ordered
                               .page(params[:page])
                               .per(20)
  end

  def chart_transactions
    @chart_transactions ||= apply_filters(@user.transactions, include_date_filter: true)
  end

  def chart_transactions_without_date
    @chart_transactions_without_date ||= apply_filters(@user.transactions, include_date_filter: false)
  end

  def income_vs_expenses_chart_data
    totals = chart_transactions.group(:transaction_type).sum(:amount)

    {
      "Income" => totals.fetch("income", 0),
      "Expenses" => totals.fetch("expense", 0)
    }
  end

  def expenses_by_category_chart_data
    chart_transactions.expense
         .joins(:category)
         .group("categories.name")
         .sum(:amount)
  end

  def monthly_evolution_chart_data
    Dashboard::MonthlyEvolutionData.new(scope: chart_transactions_without_date).call
  end

  def load_categories
    @categories = Current.user.categories.ordered
  end

  def export_filename
    "transactions-#{Date.current}.csv"
  end

  def charts_cache_key
    [
      "dashboard/charts",
      @user.id,
      filter_cache_params,
      @user.transactions.maximum(:updated_at)&.to_i
    ]
  end

  def filter_cache_params
    params.slice("transaction_type", "category_id", "search", "period", "start_date", "end_date").to_unsafe_h
  end

  def apply_filters(scope, include_date_filter:)
    scope = scope.by_type(params[:transaction_type]) if params[:transaction_type].present?
    scope = scope.by_category(params[:category_id]) if params[:category_id].present?
    scope = scope.search_description(params[:search]) if params[:search].present?
    return scope unless include_date_filter

    case params[:period]
    when "today"
      scope.where(date: Date.current)
    when "week"
      scope.where(date: Date.current.beginning_of_week..Date.current.end_of_week)
    when "month"
      scope.by_month(Date.current)
    when "custom"
      if params[:start_date].present? && params[:end_date].present?
        scope.by_date_range(params[:start_date], params[:end_date])
      else
        scope
      end
    else
      scope
    end
  end
end
