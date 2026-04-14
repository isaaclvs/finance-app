class AddMonthlyBudgetLimitToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :monthly_budget_limit, :decimal, precision: 10, scale: 2
  end
end
