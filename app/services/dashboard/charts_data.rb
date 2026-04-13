module Dashboard
  class ChartsData
    def initialize(scope:)
      @scope = scope
    end

    def call
      {
        income_vs_expenses: income_vs_expenses,
        expenses_by_category: expenses_by_category
      }
    end

    private

    def income_vs_expenses
      totals = @scope.group(:transaction_type).sum(:amount)

      {
        "Income" => totals.fetch("income", 0),
        "Expenses" => totals.fetch("expense", 0)
      }
    end

    def expenses_by_category
      @scope.expense
            .joins(:category)
            .group("categories.name")
            .sum(:amount)
    end
  end
end
