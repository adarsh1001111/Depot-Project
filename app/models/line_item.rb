class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true

  validates :product_id, uniqueness: { scope: :cart_id, message: "one product can be added only once in the cart" }, if: -> { cart_id.present? }
  validates :cart, presence:true, if: -> { cart_id.present? }
  # this has to be there cause if the cart_id is present but the cart with that id doesn't exist, then also the uniqueness constraint would have given valid true

  def total_price
    product.price*quantity
  end
end
