class CreateBorrows < ActiveRecord::Migration[8.0]
  def change
    create_table :borrows do |t|
      t.references :book, null: false, foreign_key: true
      t.references :borrower, null: false, foreign_key: { to_table: :users }
      t.datetime :borrowed_at
      t.datetime :returned_at

      t.timestamps
    end
  end
end
