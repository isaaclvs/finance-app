module Dashboard
  class MonthComparisonData
    METRICS = {
      income: "Income",
      expenses: "Expenses",
      balance: "Balance"
    }.freeze

    def initialize(scope:, reference_date: Date.current)
      @scope = scope
      @reference_date = reference_date.to_date
    end

    def call
      {
        current_month_label: current_month.strftime("%b %Y"),
        previous_month_label: previous_month.strftime("%b %Y"),
        metrics: build_metrics
      }
    end

    private

    def build_metrics
      current_totals = totals_for(current_month)
      previous_totals = totals_for(previous_month)

      METRICS.each_with_object({}) do |(key, label), metrics|
        metrics[key] = build_metric(
          label: label,
          current_amount: current_totals.fetch(key, 0),
          previous_amount: previous_totals.fetch(key, 0)
        )
      end
    end

    def build_metric(label:, current_amount:, previous_amount:)
      absolute_change = current_amount - previous_amount

      {
        label: label,
        current_amount: current_amount,
        previous_amount: previous_amount,
        absolute_change: absolute_change,
        percentage_change: percentage_change_for(current_amount, previous_amount),
        direction: direction_for(absolute_change)
      }
    end

    def totals_for(month)
      grouped = @scope.where(date: month.all_month).group(:transaction_type).sum(:amount)
      income = grouped.fetch("income", 0)
      expenses = grouped.fetch("expense", 0)

      {
        income: income,
        expenses: expenses,
        balance: income - expenses
      }
    end

    def percentage_change_for(current_amount, previous_amount)
      return nil if previous_amount.zero?

      ((current_amount - previous_amount) / previous_amount.to_f) * 100
    end

    def direction_for(amount)
      return :up if amount.positive?
      return :down if amount.negative?

      :flat
    end

    def current_month
      @reference_date.beginning_of_month
    end

    def previous_month
      current_month.prev_month
    end
  end
end
