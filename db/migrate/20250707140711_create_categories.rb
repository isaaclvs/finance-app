class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :color, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :categories, [ :user_id, :name ], unique: true
  end
end
