class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :categories, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :goals, dependent: :destroy

  # Balance calculation methods
  def total_income
    overall_totals[:income]
  end

  def total_expenses
    overall_totals[:expenses]
  end

  def balance
    balance_data[:balance]
  end

  def balance_data
    totals = overall_totals

    {
      income: totals[:income],
      expenses: totals[:expenses],
      balance: totals[:income] - totals[:expenses]
    }
  end

  def monthly_income(month = Date.current)
    monthly_totals(month)[:income]
  end

  def monthly_expenses(month = Date.current)
    monthly_totals(month)[:expenses]
  end

  def monthly_balance(month = Date.current)
    totals = monthly_totals(month)
    totals[:income] - totals[:expenses]
  end

  def yearly_income(year = Date.current.year)
    yearly_totals(year)[:income]
  end

  def yearly_expenses(year = Date.current.year)
    yearly_totals(year)[:expenses]
  end

  def yearly_balance(year = Date.current.year)
    totals = yearly_totals(year)
    totals[:income] - totals[:expenses]
  end

  private

  def overall_totals
    @overall_totals ||= grouped_totals_for(transactions)
  end

  def monthly_totals(month)
    @monthly_totals ||= {}

    month_key = month.beginning_of_month
    @monthly_totals[month_key] ||= grouped_totals_for(transactions.by_month(month_key))
  end

  def yearly_totals(year)
    @yearly_totals ||= {}

    @yearly_totals[year] ||= grouped_totals_for(
      transactions.by_year(year)
    )
  end

  def grouped_totals_for(scope)
    totals = scope.group(:transaction_type).sum(:amount)

    {
      income: totals.fetch("income", 0),
      expenses: totals.fetch("expense", 0)
    }
  end
end
