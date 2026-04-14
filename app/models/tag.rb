class Tag < ApplicationRecord
  belongs_to :user
  has_many :transaction_taggings,
           class_name: "TransactionTagging",
           foreign_key: :tag_id,
           dependent: :destroy,
           inverse_of: :tag
  has_many :transactions, through: :transaction_taggings, source: :transaction_record

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :color,
            presence: true,
            format: { with: /\A#[0-9A-F]{6}\z/i,
                      message: "must be a valid hex color (e.g. #FF5733)" }

  scope :ordered, -> { order(:name) }
end