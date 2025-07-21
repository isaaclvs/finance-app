class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :categories, dependent: :destroy
  has_many :transactions, dependent: :destroy

  # Balance calculation methods
  def total_income
    transactions.income.sum(:amount)
  end

  def total_expenses
    transactions.expense.sum(:amount)
  end

  def balance
    total_income - total_expenses
  end

  def balance_data
    {
      income: total_income,
      expenses: total_expenses,
      balance: balance
    }
  end

  def monthly_income(month = Date.current)
    transactions.income.by_month(month).sum(:amount)
  end

  def monthly_expenses(month = Date.current)
    transactions.expense.by_month(month).sum(:amount)
  end

  def monthly_balance(month = Date.current)
    monthly_income(month) - monthly_expenses(month)
  end

  def yearly_income(year = Date.current.year)
    transactions.income.where(date: Date.new(year).beginning_of_year..Date.new(year).end_of_year).sum(:amount)
  end

  def yearly_expenses(year = Date.current.year)
    transactions.expense.where(date: Date.new(year).beginning_of_year..Date.new(year).end_of_year).sum(:amount)
  end

  def yearly_balance(year = Date.current.year)
    yearly_income(year) - yearly_expenses(year)
  end
end
