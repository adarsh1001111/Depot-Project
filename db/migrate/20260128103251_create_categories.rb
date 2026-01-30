class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.timestamps
      t.string :name
      t.integer :category_id
      t.integer :products_count, default: 0
    end
  end
end
