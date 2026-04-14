module Dashboard
  class CategoryBudgetAlerts
    WARNING_THRESHOLD = 80
    EXCEEDED_THRESHOLD = 100

    Alert = Struct.new(
      :category,
      :limit_amount,
      :spent_amount,
      :percentage,
      :level,
      keyword_init: true
    ) do
      def warning?
        level == :warning
      end

      def exceeded?
        level == :exceeded
      end
    end

    def initialize(scope:, categories:)
      @scope = scope
      @categories = categories
    end

    def call
      spending_by_category = expense_scope.group(:category_id).sum(:amount)

      budgeted_categories.filter_map do |category|
        limit_amount = category.monthly_budget_limit
        spent_amount = spending_by_category.fetch(category.id, 0)
        percentage = percentage_for(spent_amount, limit_amount)
        level = level_for(percentage)

        next unless level

        Alert.new(
          category: category,
          limit_amount: limit_amount,
          spent_amount: spent_amount,
          percentage: percentage,
          level: level
        )
      end.sort_by { |alert| [ -alert.percentage, alert.category.name ] }
    end

    private

    def expense_scope
      @scope.by_type(:expense)
    end

    def budgeted_categories
      @categories.select do |category|
        category.expense_category? && category.monthly_budget_limit.present?
      end
    end

    def percentage_for(spent_amount, limit_amount)
      return 0 if limit_amount.blank? || limit_amount.zero?

      ((spent_amount.to_d / limit_amount) * 100).round(1)
    end

    def level_for(percentage)
      return :exceeded if percentage >= EXCEEDED_THRESHOLD
      return :warning if percentage >= WARNING_THRESHOLD

      nil
    end
  end
end
