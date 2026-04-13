module Dashboard
  class MonthlyEvolutionData
    def initialize(scope:, months_back: 6)
      @scope = scope
      @months_back = months_back
    end

    def call
      build_chart_data(monthly_totals)
    end

    private

    def monthly_totals
      start_date = (@months_back - 1).months.ago.beginning_of_month
      end_date = Date.current.end_of_month

      raw = @scope.where(date: start_date..end_date)
                  .group("TO_CHAR(date, 'YYYY-MM')", :transaction_type)
                  .sum(:amount)

      raw.each_with_object(Hash.new(0)) do |((month_key, transaction_type), amount), acc|
        acc[[ month_key, transaction_type ]] = amount
      end
    end

    def build_chart_data(totals)
      (0...@months_back).each_with_object({}) do |offset, chart|
        month = offset.months.ago.beginning_of_month
        month_key = month.strftime("%Y-%m")

        chart[month.strftime("%b %Y")] = {
          "Income" => totals.fetch([ month_key, "income" ], 0),
          "Expenses" => totals.fetch([ month_key, "expense" ], 0)
        }
      end
    end
  end
end
