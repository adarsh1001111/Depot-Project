class Product < ApplicationRecord
  has_many :line_items
  belongs_to :category, counter_cache: true
  has_one_attached :image

  before_destroy :ensure_not_referenced_by_any_line_item
  after_create_commit :increment_parent_product_count, if: -> { category.category_id? }
  after_destroy_commit :decrement_parent_product_count, if: -> { category.category_id? }
  after_update_commit :update_product_count, if: -> { saved_change_to_category_id && category.category_id? }
  after_commit -> { broadcast_refresh_later_to "products" }
  # The above line tells Rails to broadcast changes to the product model to any clients that are listening.

  validates :title, :description, :image, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :title, uniqueness: true
  validates :title, length: { minimum: 10 }
  validate :acceptable_image

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
