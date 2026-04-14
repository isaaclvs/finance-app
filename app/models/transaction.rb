class Transaction < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :category
  has_many :transaction_taggings,
           class_name: "TransactionTagging",
           foreign_key: :transaction_id,
           dependent: :destroy,
           inverse_of: :transaction_record
  has_many :tags, through: :transaction_taggings, source: :tag

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
  validate :tags_belong_to_user

  # Scopes
  scope :ordered, -> { order(date: :desc, created_at: :desc) }
  scope :recent, -> { ordered.limit(10) }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }
  scope :by_year, ->(year) { where(date: Date.new(year).beginning_of_year..Date.new(year).end_of_year) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_tag, ->(tag_id) { joins(:transaction_taggings).where(transaction_taggings: { tag_id: tag_id }).distinct }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :search_description, ->(term) { where("description ILIKE ?", "%#{term}%") if term.present? }

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
    "#{sign}#{ActionController::Base.helpers.number_to_currency(amount)}"
  end

  private

  def tags_belong_to_user
    return if tags.empty?

    errors.add(:tags, :invalid) if tags.any? { |tag| tag.user_id != user_id }
  end
end
