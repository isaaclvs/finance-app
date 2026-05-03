module Import
  class TransactionsImporter
    DEFAULT_CATEGORY_COLOR = "#6B7280".freeze

    def initialize(user:, preview_payload:)
      @user = user
      @preview_payload = preview_payload
    end

    def call
      rows = @preview_payload.with_indifferent_access[:rows] || []
      importable_rows = rows.select { |row| row.with_indifferent_access[:importable] }

      imported_count = 0

      ActiveRecord::Base.transaction do
        importable_rows.each do |raw_row|
          row = raw_row.with_indifferent_access

          category = find_or_create_category(row[:category_name])
          tags = find_or_create_tags(row[:tag_names] || [])

          transaction = @user.transactions.create!(
            date: row[:date],
            amount: row[:amount],
            transaction_type: row[:transaction_type],
            description: row[:description],
            category: category,
            tags: tags
          )

          imported_count += 1 if transaction.persisted?
        end
      end

      {
        imported_count: imported_count,
        skipped_count: rows.size - imported_count
      }
    end

    private

    def find_or_create_category(category_name)
      normalized = category_name.to_s.strip
      @user.categories.find_or_create_by!(name: normalized) do |category|
        category.color = DEFAULT_CATEGORY_COLOR
      end
    end

    def find_or_create_tags(tag_names)
      tag_names.map do |tag_name|
        @user.tags.find_or_create_by!(name: tag_name.to_s.strip) do |tag|
          tag.color = DEFAULT_CATEGORY_COLOR
        end
      end
    end
  end
end
