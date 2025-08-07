class Goal < ApplicationRecord
  # Concerns
  include Progressable

  # Associations
  belongs_to :user
  belongs_to :category, optional: true

  # Enums
  enum :goal_type, {
    savings: "savings",
    expense_reduction: "expense_reduction",
    income_increase: "income_increase",
    debt_payoff: "debt_payoff"
  }

  enum :status, {
    active: "active",
    completed: "completed",
    paused: "paused",
    cancelled: "cancelled"
  }

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :target_amount, numericality: { greater_than: 0 }
  validates :target_date, presence: true
  validates :goal_type, presence: true
  validates :status, presence: true

  validate :target_date_cannot_be_in_the_past, on: :create
  validate :current_amount_cannot_exceed_target

  # Scopes
  scope :ordered, -> { order(:target_date, :created_at) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_type, ->(type) { where(goal_type: type) }
  scope :active_goals, -> { where(status: "active") }
  scope :completed_goals, -> { where(status: "completed") }
  scope :overdue, -> { where("target_date < ? AND status = ?", Date.current, "active") }
  scope :due_soon, -> { where(target_date: Date.current..1.week.from_now, status: "active") }

  # Instance methods

  def overdue?
    target_date < Date.current && active?
  end

  def due_soon?
    target_date <= 1.week.from_now && active?
  end

  def completed?
    status == "completed" || current_amount >= target_amount
  end

  def can_complete?
    current_amount >= target_amount
  end

  def mark_completed!
    update!(status: "completed") if can_complete?
  end

  def days_remaining
    return 0 if overdue?
    (target_date - Date.current).to_i
  end

  def goal_type_color
    {
      "savings" => "emerald",
      "expense_reduction" => "red",
      "income_increase" => "blue",
      "debt_payoff" => "purple"
    }[goal_type] || "gray"
  end

  def status_color
    {
      "active" => "blue",
      "completed" => "green",
      "paused" => "yellow",
      "cancelled" => "gray"
    }[status] || "gray"
  end

  private

  def target_date_cannot_be_in_the_past
    return unless target_date.present? && target_date < Date.current

    errors.add(:target_date, "can't be in the past")
  end

  def current_amount_cannot_exceed_target
    return unless current_amount.present? && target_amount.present?
    return unless current_amount > target_amount

    errors.add(:current_amount, "can't be greater than target amount")
  end
end
