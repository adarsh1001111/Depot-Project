class Product < ApplicationRecord
  PERMALINK_REGEX = /\A[a-zA-Z0-9]+(-[a-zA-Z0-9]+){2,}\z/.freeze
  WORD_REGEX = /\w+/.freeze
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  has_one_attached :image
  after_commit -> { broadcast_refresh_later_to "products" }
  # The above line tells Rails to broadcast changes to the product model to any clients that are listening.

  validates :title, :description, :image, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01, greater_than: :discount_price }, allow_nil: true
  validates :title, uniqueness: true
  validates :title, length: { minimum: 10 }
  validate :acceptable_image
  validates :permalink, uniqueness: true,
    format: { with: PERMALINK_REGEX }
  validates :words_in_description, length: { minimum: 5, maximum: 10 }
  validates :image_url, url: true
  validate :ensure_discount_less_than_price

  def ensure_discount_less_than_price
    unless price > discount_price
      errors.add(:price, "price should be greater than discount_price")
    end
  end

  def words_in_description
    description&.scan(WORD_REGEX)
  end

  order :title
  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png", "image/webp" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a GIF, JPG, PNG or WEBP")
    end
  end
private

  # ensure that there are no line items referencing this product
  def ensure_not_referenced_by_any_line_item
    unless line_items.empty?
      errors.add(:base, "Line Items present")
      throw :abort
    end
  end
end
