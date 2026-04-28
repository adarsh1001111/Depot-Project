class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :user_id, uniqueness: { scope: :product_id }
  validates :value, inclusion: { in: (0..10).map { |i| i * 0.5 } }
end
