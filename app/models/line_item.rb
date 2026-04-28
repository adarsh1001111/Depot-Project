class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true, counter_cache: true

  validates :product_id, uniqueness: { scope: :cart_id, message: :line_item_unique_in_cart }, if: -> { cart_id? }
  validates :cart, presence: true, if: -> { cart_id? }
  # this has to be there cause if the cart_id is present but the cart with that id doesn't exist, then also the uniqueness constraint would have given valid true

  def total_price
    product.price*quantity
  end
end
