require "rails_helper"

RSpec.describe Import::TransactionsImporter do
  describe "#call" do
    let(:user) { create(:user) }

    it "imports only rows flagged as importable" do
      payload = {
        rows: [
          {
            date: Date.new(2026, 5, 1),
            amount: "100.0",
            transaction_type: "income",
            category_name: "Salary",
            description: "May salary",
            tag_names: [ "work" ],
            importable: true
          },
          {
            date: Date.new(2026, 5, 1),
            amount: "100.0",
            transaction_type: "income",
            category_name: "Salary",
            description: "May salary",
            tag_names: [],
            importable: false
          }
        ]
      }

      result = described_class.new(user: user, preview_payload: payload).call

      expect(result[:imported_count]).to eq(1)
      expect(result[:skipped_count]).to eq(1)
      expect(user.transactions.count).to eq(1)
      expect(user.categories.find_by(name: "Salary")).to be_present
      expect(user.tags.find_by(name: "work")).to be_present
    end
  end
end
