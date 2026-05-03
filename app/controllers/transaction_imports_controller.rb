class TransactionImportsController < ApplicationController
  PREVIEW_CACHE_TTL = 30.minutes

  before_action :load_categories_and_tags, only: %i[new preview]

  def new
  end

  def preview
    file = params.dig(:import, :file)

    if file.blank?
      redirect_to new_transaction_import_path, alert: t("notices.transaction_imports.file_required")
      return
    end

    parser_result = Import::TransactionsCsvParser.new(file: file).call

    if parser_result[:file_error].present?
      redirect_to new_transaction_import_path, alert: parser_result[:file_error]
      return
    end

    @preview = Import::TransactionsPreview.new(
      user: Current.user,
      parsed_rows: parser_result[:rows],
      row_errors: parser_result[:row_errors]
    ).call

    persist_preview!(@preview)
  end

  def create
    preview_payload = read_preview!

    if preview_payload.blank?
      redirect_to new_transaction_import_path, alert: t("notices.transaction_imports.preview_expired")
      return
    end

    result = Import::TransactionsImporter.new(user: Current.user, preview_payload: preview_payload).call

    clear_preview!

    redirect_to transactions_path, notice: t(
      "notices.transaction_imports.imported",
      imported_count: result[:imported_count],
      skipped_count: result[:skipped_count]
    )
  end

  private

  def load_categories_and_tags
    @categories = Current.user.categories.ordered
    @tags = Current.user.tags.ordered
  end

  def preview_cache_key
    "transaction-import-preview:#{Current.user.id}:#{session.id}"
  end

  def persist_preview!(payload)
    Rails.cache.write(preview_cache_key, payload, expires_in: PREVIEW_CACHE_TTL)
  end

  def read_preview!
    Rails.cache.read(preview_cache_key)
  end

  def clear_preview!
    Rails.cache.delete(preview_cache_key)
  end
end
