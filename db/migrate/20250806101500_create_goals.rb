class CreateGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :goals do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :target_amount, precision: 10, scale: 2, null: false
      t.decimal :current_amount, precision: 10, scale: 2, default: 0.0, null: false
      t.date :target_date, null: false
      t.string :goal_type, null: false
      t.string :status, default: 'active', null: false
      t.references :user, null: false, foreign_key: true
      t.references :category, null: true, foreign_key: true

      t.timestamps
    end

    add_index :goals, [ :user_id, :status ]
    add_index :goals, [ :user_id, :goal_type ]
    add_index :goals, [ :user_id, :target_date ]
  end
end
