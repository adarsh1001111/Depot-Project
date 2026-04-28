class Product < ApplicationRecord
  belongs_to :category, counter_cache: true
  has_one_attached :image
  has_many_attached :images
  has_many :line_items, dependent: :restrict_with_error
  has_many :carts, through: :line_items
  has_many :ratings, dependent: :destroy
  PERMALINK_REGEX = /\A\w+(-\w+){2,}\z/.freeze
  WORD_REGEX = /\w+/.freeze
  FIVE_TO_TEN_WORDS_REGEX = /\A(\w+\s+){4,9}\w+\z/.freeze

  before_destroy :ensure_not_referenced_by_any_line_item
  after_create_commit :increment_parent_product_count, if: -> { category.category_id? }
  after_destroy_commit :decrement_parent_product_count, if: -> { category.category_id? }
  after_update_commit :update_product_count, if: -> { saved_change_to_category_id && category.category_id? }
  after_commit -> { broadcast_refresh_later_to "products" }
  # The above line tells Rails to broadcast changes to the product model to any clients that are listening.

  validates :title, :description, presence: true
  validates :category, presence: { message: :must_be_selected }
  validates :price, numericality: { greater_than_or_equal_to: 0.01, greater_than: :discount_price }, allow_nil: true
  validates :title, uniqueness: true
  validates :title, length: { minimum: 10 }
  validate :images_presence
  validate :acceptable_images
  validates :permalink, uniqueness: true,
    format: { with: PERMALINK_REGEX }
  validate :words_in_description
  validates :description, format: { with: FIVE_TO_TEN_WORDS_REGEX, message: :description_word_count_invalid }, allow_nil: true
  validates :image_url, url: true

  # custom validator method for price and discount
  validate :ensure_discount_less_than_price

  after_initialize :set_defaults

  scope :enabled_products, -> { where(enabled: true) }
  scope :present_in_line_items, -> { joins(:line_items).distinct }
  scope :titles_present_in_line_items, -> { joins(:line_items).distinct.pluck(:title) }

  order :title

  def average_rating
    ratings.average(:value).to_f.round(1)
  end

  private def set_defaults
    self.title = "abc" if title.blank?
    self.discount_price = self.price if discount_price.blank?
  end

  def all_images
    if images.attached?
      images
    elsif image.attached?
      [ image ]
    else
      []
    end
  end

  private def images_presence
    errors.add(:images, :must_be_attached) unless image.attached? || images.attached?
  end

  private def acceptable_images
    return unless image.attached? || images.attached?

    all_images = self.all_images
    if all_images.count > 3
      errors.add(:images, :too_many_images)
    end

    acceptable_types = [ "image/gif", "image/jpeg", "image/png", "image/webp" ]
    all_images.each do |image_attachment|
      unless acceptable_types.include?(image_attachment.content_type)
        errors.add(:images, :invalid_image_type)
      end
    end
  end

  private def ensure_discount_less_than_price
    if price != nil && price < discount_price
      errors.add(:price, :price_must_exceed_discount)
    end
  end

  private def words_in_description
    unless description.nil?
      description_words_array = description.scan(WORD_REGEX)

      return if description_words_array.length.between?(5, 10)
    end
      errors.add(:description, :description_word_count_invalid)
  end

  # ensure that there are no line items referencing this product
  private def ensure_not_referenced_by_any_line_item
    unless line_items.empty?
      errors.add(:base, :line_items_present)
      throw :abort
    end
  end

  private def increment_parent_product_count
    category.category.increment!(:products_count, 1)
  end

  private def decrement_parent_product_count
    category.category.decrement!(:products_count, 1)
  end

  private def update_product_count
    prev_fk = saved_change_to_category_id.first
    new_fk = saved_change_to_category_id.last
    Category.find(prev_fk).category.decrement!(:products_count, 1)
    Category.find(new_fk).category.increment!(:products_count, 1)
  end
end
