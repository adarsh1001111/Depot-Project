class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :value, precision: 2, scale: 1, null: false

      t.timestamps
    end

    add_index :ratings, [ :user_id, :product_id ], unique: true
  end
end
