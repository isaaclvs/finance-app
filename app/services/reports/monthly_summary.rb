module Reports
  class MonthlySummary
    def initialize(user:, reference_date:)
      @user = user
      @reference_date = reference_date.beginning_of_month
    end

    def call
      income = scoped_transactions.income.sum(:amount)
      expenses = scoped_transactions.expense.sum(:amount)

      {
        month: @reference_date.strftime("%Y-%m"),
        income: income,
        expenses: expenses,
        balance: income - expenses
      }
    end

    private

    def scoped_transactions
      @user.transactions.by_month(@reference_date)
    end
  end
end
