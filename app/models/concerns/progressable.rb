module Progressable
  extend ActiveSupport::Concern

  included do
    validates :current_amount, :target_amount, presence: true
    validates :current_amount, :target_amount,
              numericality: { greater_than_or_equal_to: 0 }
  end

  def update_progress(amount)
    return false unless amount.is_a?(Numeric)

    new_amount = [ amount, 0 ].max

    if update(current_amount: new_amount)
      check_completion_status if respond_to?(:check_completion_status, true)
      true
    else
      false
    end
  end

  def add_progress(amount)
    return false unless amount.is_a?(Numeric) && amount > 0

    update_progress(current_amount + amount)
  end

  def subtract_progress(amount)
    return false unless amount.is_a?(Numeric) && amount > 0

    new_amount = [ current_amount - amount, 0 ].max
    update_progress(new_amount)
  end

  def progress_percentage
    return 0.0 if target_amount.zero?

    percentage = (current_amount.to_f / target_amount.to_f) * 100
    [ percentage, 100.0 ].min.round(1)
  end

  def remaining_amount
    [ target_amount - current_amount, 0 ].max
  end

  def progress_ratio
    return 0.0 if target_amount.zero?

    ratio = current_amount.to_f / target_amount.to_f
    [ ratio, 1.0 ].min
  end

  def completed_progress?
    current_amount >= target_amount
  end

  private

  def check_completion_status
    return unless respond_to?(:can_complete?) && respond_to?(:mark_completed!)

    mark_completed! if can_complete? && respond_to?(:status) && status != "completed"
  end
end
