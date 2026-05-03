require "csv"
require "bigdecimal"

module Import
  class TransactionsCsvParser
    REQUIRED_HEADERS = %w[date amount type category].freeze

    def initialize(file:)
      @file = file
    end

    def call
      csv = read_csv
      return { file_error: I18n.t("transaction_imports.errors.invalid_csv") } if csv.blank?

      headers = csv.headers.map { |h| normalize_header(h) }
      return { file_error: missing_headers_message(headers) } if missing_headers?(headers)

      rows = []
      row_errors = []

      csv.each_with_index do |row, idx|
        line_number = idx + 2
        parsed = parse_row(row.to_h.transform_keys { |key| normalize_header(key) }, line_number)

        if parsed[:errors].any?
          row_errors << { line: line_number, errors: parsed[:errors] }
        else
          rows << parsed[:data]
        end
      end

      { rows: rows, row_errors: row_errors, file_error: nil }
    rescue CSV::MalformedCSVError
      { file_error: I18n.t("transaction_imports.errors.invalid_csv") }
    end

    private

    def read_csv
      content = @file.respond_to?(:read) ? @file.read : @file.to_s
      CSV.parse(content, headers: true)
    end

    def normalize_header(header)
      header.to_s.strip.downcase
    end

    def missing_headers?(headers)
      (REQUIRED_HEADERS - headers).any?
    end

    def missing_headers_message(headers)
      missing = REQUIRED_HEADERS - headers
      I18n.t("transaction_imports.errors.missing_headers", headers: missing.join(", "))
    end

    def parse_row(raw_row, line_number)
      errors = []

      date = parse_date(raw_row["date"])
      errors << I18n.t("transaction_imports.errors.invalid_date", line: line_number) if date.nil?

      amount = parse_amount(raw_row["amount"])
      errors << I18n.t("transaction_imports.errors.invalid_amount", line: line_number) if amount.nil? || amount <= 0

      transaction_type = parse_type(raw_row["type"])
      errors << I18n.t("transaction_imports.errors.invalid_type", line: line_number) if transaction_type.nil?

      category_name = raw_row["category"].to_s.strip
      errors << I18n.t("transaction_imports.errors.missing_category", line: line_number) if category_name.blank?

      tags = raw_row["tags"].to_s.split(",").map(&:strip).reject(&:blank?)

      {
        data: {
          date: date,
          amount: amount,
          transaction_type: transaction_type,
          category_name: category_name,
          description: raw_row["description"].to_s.strip,
          tag_names: tags,
          line_number: line_number
        },
        errors: errors
      }
    end

    def parse_date(value)
      return nil if value.blank?

      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    def parse_amount(value)
      return nil if value.blank?

      normalized = value.to_s.strip
      normalized = normalized.gsub(".", "").gsub(",", ".") if normalized.match?(/\A-?[\d.]+,[\d]{1,2}\z/)
      BigDecimal(normalized)
    rescue ArgumentError
      nil
    end

    def parse_type(value)
      normalized = value.to_s.strip.downcase

      return "income" if %w[income receita entrada].include?(normalized)
      return "expense" if %w[expense despesa saida saída].include?(normalized)

      nil
    end
  end
end
