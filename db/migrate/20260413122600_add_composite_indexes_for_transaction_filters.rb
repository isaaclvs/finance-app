class AddCompositeIndexesForTransactionFilters < ActiveRecord::Migration[8.0]
  def change
    add_index :transactions,
              [ :user_id, :transaction_type, :date ],
              name: "index_transactions_on_user_type_and_date"

    add_index :transactions,
              [ :user_id, :category_id, :date ],
              name: "index_transactions_on_user_category_and_date"
  end
end
