class AddBorrowableToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :borrowable, :boolean
  end
end
