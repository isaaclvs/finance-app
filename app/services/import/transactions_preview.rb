require "set"

module Import
  class TransactionsPreview
    def initialize(user:, parsed_rows:, row_errors: [])
      @user = user
      @parsed_rows = parsed_rows
      @row_errors = row_errors
    end

    def call
      existing_signatures = build_existing_signatures
      seen_signatures = Set.new

      rows = @parsed_rows.map do |row|
        signature = transaction_signature(row)

        duplicate_in_file = seen_signatures.include?(signature)
        seen_signatures << signature

        duplicate_existing = existing_signatures.include?(signature)

        row.merge(
          signature: signature,
          duplicate_in_file: duplicate_in_file,
          duplicate_existing: duplicate_existing,
          importable: !duplicate_in_file && !duplicate_existing
        )
      end

      {
        rows: rows,
        row_errors: @row_errors,
        summary: build_summary(rows)
      }
    end

    private

    def build_summary(rows)
      {
        total_rows: @parsed_rows.size + @row_errors.size,
        valid_rows: @parsed_rows.size,
        invalid_rows: @row_errors.size,
        duplicate_in_file_count: rows.count { |row| row[:duplicate_in_file] },
        duplicate_existing_count: rows.count { |row| row[:duplicate_existing] },
        importable_count: rows.count { |row| row[:importable] }
      }
    end

    def build_existing_signatures
      start_date = @parsed_rows.map { |row| row[:date] }.min
      end_date = @parsed_rows.map { |row| row[:date] }.max
      return Set.new if start_date.blank? || end_date.blank?

      category_map = @user.categories.index_by { |category| normalize_text(category.name) }

      @user.transactions
           .where(date: start_date..end_date)
           .includes(:category)
           .map do |transaction|
        normalized = {
          date: transaction.date,
          amount: transaction.amount,
          transaction_type: transaction.transaction_type,
          category_name: transaction.category&.name.to_s,
          description: transaction.description.to_s
        }

        transaction_signature(normalized)
      end.to_set
    end

    def transaction_signature(row)
      [
        row[:date].to_s,
        BigDecimal(row[:amount].to_s).to_s("F"),
        row[:transaction_type].to_s,
        normalize_text(row[:category_name]),
        normalize_text(row[:description])
      ].join("|")
    end

    def normalize_text(value)
      value.to_s.strip.downcase.gsub(/\s+/, " ")
    end
  end
end
