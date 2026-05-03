class Goal < ApplicationRecord
  # Concerns
  include Progressable

  # Associations
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :parent_goal, class_name: "Goal", optional: true
  has_many :child_goals, class_name: "Goal", foreign_key: :parent_goal_id, dependent: :nullify

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
    cancelled: "cancelled",
    rolled_over: "rolled_over"
  }

  # Callbacks
  before_create :set_period_dates_if_recurring

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
  scope :recurring_goals, -> { where(recurring: true) }
  scope :history, -> { where(status: "rolled_over") }
  scope :pending_rollover, -> { recurring_goals.active.where("period_end < ?", Date.current) }

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

  def rollover!
    return false unless recurring? && active?

    next_month_start = (period_end || Date.current).next_month.beginning_of_month
    next_month_end   = next_month_start.end_of_month
    root_id = parent_goal_id || id

    new_goal = self.class.create!(
      title: title,
      description: description,
      target_amount: target_amount,
      current_amount: 0.0,
      goal_type: goal_type,
      category_id: category_id,
      user_id: user_id,
      recurring: true,
      parent_goal_id: root_id,
      period_start: next_month_start,
      period_end: next_month_end,
      target_date: next_month_end,
      status: "active"
    )

    update!(status: "rolled_over")
    new_goal
  end

  def current_period_label
    return nil unless period_start && period_end

    period_start.strftime("%b/%Y")
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
      "cancelled" => "gray",
      "rolled_over" => "slate"
    }[status] || "gray"
  end

  private

  def set_period_dates_if_recurring
    return unless recurring? && period_start.nil?

    ref = target_date || Date.current
    self.period_start = ref.beginning_of_month
    self.period_end   = ref.end_of_month
  end

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
