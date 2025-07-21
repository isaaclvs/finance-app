class DashboardController < ApplicationController
  def index
    @user = Current.user
    @recent_transactions = @user.transactions.includes(:category).ordered.limit(10)
    
    @income_vs_expenses_data = income_vs_expenses_chart_data
    @expenses_by_category_data = expenses_by_category_chart_data
    @monthly_evolution_data = monthly_evolution_chart_data
  end

  private

  def income_vs_expenses_chart_data
    {
      "Income" => @user.total_income,
      "Expenses" => @user.total_expenses
    }
  end

  def expenses_by_category_chart_data
    @user.transactions.expense
         .joins(:category)
         .group("categories.name")
         .sum(:amount)
  end

  def monthly_evolution_chart_data
    data = {}
    
    (0..5).each do |i|
      month = i.months.ago.beginning_of_month
      month_transactions = @user.transactions.by_month(month)
      
      data[month.strftime("%b %Y")] = {
        "Income" => month_transactions.income.sum(:amount),
        "Expenses" => month_transactions.expense.sum(:amount)
      }
    end
    
    data
  end
end