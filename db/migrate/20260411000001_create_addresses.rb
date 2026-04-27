class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.string :state, null: false
      t.string :city, null: false
      t.string :country, null: false
      t.string :pincode, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
