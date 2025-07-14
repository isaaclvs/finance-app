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
end
