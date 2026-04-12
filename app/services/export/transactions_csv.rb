require "csv"

module Export
  class TransactionsCsv
    HEADERS = [ "Date", "Type", "Category", "Description", "Amount" ].freeze

    def initialize(transactions:)
      @transactions = transactions.includes(:category)
    end

    def call
      CSV.generate(headers: true) do |csv|
        csv << HEADERS

        @transactions.each do |transaction|
          csv << [
            transaction.date,
            transaction.transaction_type,
            transaction.category_name,
            transaction.description,
            format("%.2f", transaction.amount)
          ]
        end
      end
    end
  end
end
