class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :date, null: false
      t.text :description
      t.string :transaction_type, null: false
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :transactions, :date
    add_index :transactions, :transaction_type
    add_index :transactions, [:user_id, :date]
  end
end
