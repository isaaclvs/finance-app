require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let(:tag) { create(:tag, user: user) }

  describe "business logic methods" do
    describe "tags association" do
      it "supports many-to-many relation with tags" do
        transaction = create(:transaction, user: user, category: category)
        transaction.tags << tag

        expect(transaction.tags).to contain_exactly(tag)
      end

      it "does not allow tags from another user" do
        other_user_tag = create(:tag, user: create(:user))
        transaction = build(:transaction, user: user, category: category)
        transaction.tags << other_user_tag

        expect(transaction).not_to be_valid
      end
    end

    describe "#income?" do
      it "returns true for income transactions" do
        transaction = create(:transaction, :income, user: user, category: category)
        expect(transaction.income?).to be true
      end

      it "returns false for expense transactions" do
        transaction = create(:transaction, :expense, user: user, category: category)
        expect(transaction.income?).to be false
      end
    end

    describe "#expense?" do
      it "returns true for expense transactions" do
        transaction = create(:transaction, :expense, user: user, category: category)
        expect(transaction.expense?).to be true
      end

      it "returns false for income transactions" do
        transaction = create(:transaction, :income, user: user, category: category)
        expect(transaction.expense?).to be false
      end
    end

    describe "#formatted_amount" do
      it "formats income with + sign" do
        transaction = create(:transaction, :income, amount: 100.50, user: user, category: category)

        formatted = I18n.with_locale(:en) { transaction.formatted_amount }
        expect(formatted).to eq("+$100.50")
      end

      it "formats expense with - sign" do
        transaction = create(:transaction, :expense, amount: 75.25, user: user, category: category)

        formatted = I18n.with_locale(:en) { transaction.formatted_amount }
        expect(formatted).to eq("-$75.25")
      end

      it "formats amounts using pt-BR locale" do
        transaction = create(:transaction, :income, amount: 100.50, user: user, category: category)

        formatted = I18n.with_locale(:"pt-BR") { transaction.formatted_amount }
        expect(formatted).to eq("+R$ 100,50")
      end
    end
  end

  describe "useful scopes" do
    before do
      reference_month = Date.new(2025, 7, 1)
      create(:transaction, :income, amount: 100, user: user, category: category, date: reference_month + 5.days)
      create(:transaction, :expense, amount: 50, user: user, category: category, date: reference_month + 10.days)
    end

    describe ".ordered" do
      it "returns transactions ordered by date desc, created_at desc" do
        transactions = Transaction.ordered
        expect(transactions.first.date).to be >= transactions.last.date
      end
    end

    describe ".by_month" do
      it "returns transactions for the given month" do
        reference_month = Date.new(2025, 7, 1)
        transactions = Transaction.by_month(reference_month)
        expect(transactions.count).to eq(2)
      end
    end

    describe ".by_type" do
      it "returns transactions of the specified type" do
        income_transactions = Transaction.by_type("income")
        expect(income_transactions.count).to eq(1)
        expect(income_transactions.first.transaction_type).to eq("income")
      end
    end
  end

  describe "class methods for calculations" do
    before do
      create(:transaction, :income, amount: 1000, user: user, category: category)
      create(:transaction, :expense, amount: 200, user: user, category: category)
    end

    describe ".balance" do
      it "calculates the balance correctly" do
        expect(Transaction.balance).to eq(800.0)
      end
    end

    describe ".total_by_type" do
      it "returns the total for the specified type" do
        expect(Transaction.total_by_type("income")).to eq(1000.0)
        expect(Transaction.total_by_type("expense")).to eq(200.0)
      end
    end
  end
end
