class DashboardController < ApplicationController
  before_action :load_categories

  def index
    @user = Current.user
    @transactions = filtered_transactions

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
    transactions = @user.transactions.includes(:category)

    # Apply filters (same logic as TransactionsController)
    transactions = transactions.by_type(params[:transaction_type]) if params[:transaction_type].present?
    transactions = transactions.by_category(params[:category_id]) if params[:category_id].present?
    transactions = transactions.search_description(params[:search]) if params[:search].present?

    if params[:period].present?
      case params[:period]
      when "today"
        transactions = transactions.where(date: Date.current)
      when "week"
        transactions = transactions.where(date: Date.current.beginning_of_week..Date.current.end_of_week)
      when "month"
        transactions = transactions.by_month(Date.current)
      when "custom"
        if params[:start_date].present? && params[:end_date].present?
          transactions = transactions.by_date_range(params[:start_date], params[:end_date])
        end
      end
    end

    transactions.ordered.page(params[:page]).per(20)
  end

  def income_vs_expenses_chart_data
    # Use filtered transactions for chart data
    filtered_income = filtered_transactions_for_charts.income.sum(:amount)
    filtered_expenses = filtered_transactions_for_charts.expense.sum(:amount)

    {
      "Income" => filtered_income,
      "Expenses" => filtered_expenses
    }
  end

  def expenses_by_category_chart_data
    filtered_transactions_for_charts.expense
         .joins(:category)
         .group("categories.name")
         .sum(:amount)
  end

  def monthly_evolution_chart_data
    data = {}
    base_query = filtered_transactions_for_charts_without_date

    (0..5).each do |i|
      month = i.months.ago.beginning_of_month
      month_transactions = base_query.by_month(month)

      data[month.strftime("%b %Y")] = {
        "Income" => month_transactions.income.sum(:amount),
        "Expenses" => month_transactions.expense.sum(:amount)
      }
    end

    data
  end

  def filtered_transactions_for_charts
    # Get transactions with all filters applied (including date)
    transactions = @user.transactions.includes(:category)
    transactions = transactions.by_type(params[:transaction_type]) if params[:transaction_type].present?
    transactions = transactions.by_category(params[:category_id]) if params[:category_id].present?
    transactions = transactions.search_description(params[:search]) if params[:search].present?

    if params[:period].present?
      case params[:period]
      when "today"
        transactions = transactions.where(date: Date.current)
      when "week"
        transactions = transactions.where(date: Date.current.beginning_of_week..Date.current.end_of_week)
      when "month"
        transactions = transactions.by_month(Date.current)
      when "custom"
        if params[:start_date].present? && params[:end_date].present?
          transactions = transactions.by_date_range(params[:start_date], params[:end_date])
        end
      end
    end

    transactions
  end

  def filtered_transactions_for_charts_without_date
    # Get transactions with filters applied (excluding date for monthly evolution)
    transactions = @user.transactions.includes(:category)
    transactions = transactions.by_type(params[:transaction_type]) if params[:transaction_type].present?
    transactions = transactions.by_category(params[:category_id]) if params[:category_id].present?
    transactions = transactions.search_description(params[:search]) if params[:search].present?
    transactions
  end

  def load_categories
    @categories = Current.user.categories.ordered
  end
end
