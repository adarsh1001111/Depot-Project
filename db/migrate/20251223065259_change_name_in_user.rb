class ChangeNameInUser < ActiveRecord::Migration[8.1]
  def change
    change_column :users, :name, :text
  end
end
