require "rails_helper"
require "csv"

RSpec.describe Export::TransactionsCsv do
  describe "#call" do
    let(:user) { create(:user) }
    let(:category) { create(:category, user: user, name: "Food") }

    it "generates CSV with expected headers and rows" do
      transaction = create(
        :transaction,
        :expense,
        user: user,
        category: category,
        amount: 45.5,
        date: Date.new(2026, 4, 10),
        description: "Lunch"
      )

      csv_content = described_class.new(transactions: Transaction.where(id: transaction.id)).call
      parsed = CSV.parse(csv_content, headers: true)

      expect(parsed.headers).to eq([ "Date", "Type", "Category", "Description", "Amount" ])
      expect(parsed.length).to eq(1)
      expect(parsed[0]["Date"]).to eq("2026-04-10")
      expect(parsed[0]["Type"]).to eq("expense")
      expect(parsed[0]["Category"]).to eq("Food")
      expect(parsed[0]["Description"]).to eq("Lunch")
      expect(parsed[0]["Amount"]).to eq("45.50")
    end
  end
end
