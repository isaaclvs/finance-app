class TransactionTagging < ApplicationRecord
  self.table_name = "transaction_tags"

  belongs_to :transaction_record,
             class_name: "Transaction",
             foreign_key: :transaction_id,
             inverse_of: :transaction_taggings
  belongs_to :tag,
             inverse_of: :transaction_taggings

  validates :tag_id, uniqueness: { scope: :transaction_id }
end