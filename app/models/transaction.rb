class Transaction < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :category
  
  # Delegations
  delegate :name, :color, to: :category, prefix: true
  
  # Enums
  enum :transaction_type, { 
    income: "income", 
    expense: "expense" 
  }
  
  # Validations
  validates :amount, presence: true, 
                     numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :transaction_type, presence: true
  validates :category, presence: true
  validates :user, presence: true
  
  # Scopes
  scope :ordered, -> { order(date: :desc, created_at: :desc) }
  scope :recent, -> { ordered.limit(10) }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }
  scope :by_year, ->(year) { where(date: Date.new(year).beginning_of_year..Date.new(year).end_of_year) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  
  # Class methods
  def self.total_by_type(type)
    by_type(type).sum(:amount)
  end
  
  def self.balance
    income.sum(:amount) - expense.sum(:amount)
  end
  
  # Instance methods
  def income?
    transaction_type == "income"
  end
  
  def expense?
    transaction_type == "expense"
  end
  
  def formatted_amount
    sign = income? ? "+" : "-"
    "#{sign}$#{'%.2f' % amount}"
  end
end
