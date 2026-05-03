class AddRecurringToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :recurring, :boolean, default: false, null: false
    add_column :goals, :parent_goal_id, :bigint
    add_column :goals, :period_start, :date
    add_column :goals, :period_end, :date

    add_foreign_key :goals, :goals, column: :parent_goal_id
    add_index :goals, :parent_goal_id
  end
end
