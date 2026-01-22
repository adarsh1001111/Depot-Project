class Product < ApplicationRecord
  PERMALINK_REGEX = /\A\w+(-\w+){2,}\z/.freeze
  WORD_REGEX = /\w+/.freeze
  FIVE_TO_TEN_WORDS_REGEX = /\A(\w+\s+){4,9}\w+\z/.freeze

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
  validate :words_in_description
  validates :description, format: { with: FIVE_TO_TEN_WORDS_REGEX, message: "must be between 5 to 10 words long." }, allow_nil: true
  validates :image_url, url: true

  # custom validator method for price and discount
  validate :ensure_discount_less_than_price

  order :title

private
  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png", "image/webp" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a GIF, JPG, PNG or WEBP")
    end
  end

  def ensure_discount_less_than_price
    return unless price? && discount_price? && price >= discount_price

    errors.add(:price, "price should be greater than discount_price")
  end

  def words_in_description
    unless description.nil?
      description_words_array = description.scan(WORD_REGEX)

      return if description_words_array.length.between?(5, 10)
    end
      errors.add(:description, "description should be between 5 to 10 words")
  end

  # ensure that there are no line items referencing this product
  def ensure_not_referenced_by_any_line_item
    unless line_items.empty?
      errors.add(:base, "Line Items present")
      throw :abort
    end
  end
end
