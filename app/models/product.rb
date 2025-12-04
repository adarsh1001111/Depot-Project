class Product < ApplicationRecord
  has_one_attached :image
  after_commit -> { broadcast_refresh_later_to "products" }
  #The above line tells Rails to broadcast changes to the product model to any clients that are listening.
end
