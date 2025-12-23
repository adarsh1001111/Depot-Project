class AddExtraFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :enabled, :boolean
    add_column :products, :discount_price, :decimal
    add_column :products, :permalink, :string
  end
end
