class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.references :borrow, null: false, foreign_key: true, index: { unique: true }
      t.references :rater, null: false, foreign_key: { to_table: :users }
      t.references :ratee, null: false, foreign_key: { to_table: :users }
      t.integer :stars, null: false
      t.text :comment

      t.timestamps
    end
  end
end
