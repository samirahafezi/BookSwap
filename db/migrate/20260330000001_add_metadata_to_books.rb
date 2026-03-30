class AddMetadataToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :author, :string
    add_column :books, :genre, :string
    add_column :books, :condition, :string
    add_column :books, :description, :text
  end
end
