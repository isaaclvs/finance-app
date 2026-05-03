require "rails_helper"

RSpec.describe Import::TransactionsPreview do
  describe "#call" do
    let(:user) { create(:user) }
    let(:category) { create(:category, user: user, name: "Food") }

    before do
      create(:transaction,
             user: user,
             category: category,
             date: Date.new(2026, 5, 1),
             amount: 20,
             transaction_type: "expense",
             description: "Lunch")
    end

    it "marks duplicates in file and existing database" do
      parsed_rows = [
        {
          date: Date.new(2026, 5, 1),
          amount: BigDecimal("20"),
          transaction_type: "expense",
          category_name: "Food",
          description: "Lunch",
          tag_names: [],
          line_number: 2
        },
        {
          date: Date.new(2026, 5, 2),
          amount: BigDecimal("30"),
          transaction_type: "expense",
          category_name: "Food",
          description: "Dinner",
          tag_names: [],
          line_number: 3
        },
        {
          date: Date.new(2026, 5, 2),
          amount: BigDecimal("30"),
          transaction_type: "expense",
          category_name: "Food",
          description: "Dinner",
          tag_names: [],
          line_number: 4
        }
      ]

      preview = described_class.new(user: user, parsed_rows: parsed_rows, row_errors: []).call

      expect(preview[:summary][:duplicate_existing_count]).to eq(1)
      expect(preview[:summary][:duplicate_in_file_count]).to eq(1)
      expect(preview[:summary][:importable_count]).to eq(1)
    end
  end
end
