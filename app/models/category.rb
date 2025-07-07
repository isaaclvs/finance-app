class Category < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true,
                   uniqueness: { scope: :user_id,
                                message: "has already been taken for this user" }
  validates :color, presence: true,
                    format: { with: /\A#[0-9A-F]{6}\z/i,
                             message: "must be a valid hex color (e.g. #FF5733)" }

  # Scopes
  scope :ordered, -> { order(:name) }

  # Default colors for categories
  DEFAULT_COLORS = {
    # Income colors (greens/blues)
    "Salary" => "#10B981",
    "Freelance" => "#3B82F6",
    "Investments" => "#6366F1",
    "Other Income" => "#14B8A6",

    # Expense colors (varied)
    "Food" => "#EF4444",
    "Transport" => "#F59E0B",
    "Housing" => "#8B5CF6",
    "Entertainment" => "#EC4899",
    "Health" => "#10B981",
    "Education" => "#3B82F6",
    "Shopping" => "#F97316",
    "Bills" => "#6B7280"
  }.freeze

  # Instance methods
  def income_category?
    %w[Salary Freelance Investments].include?(name) || name.include?("Income")
  end

  def expense_category?
    !income_category?
  end
end
