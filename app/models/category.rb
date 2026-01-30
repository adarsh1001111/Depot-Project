class Category < ApplicationRecord
  has_many :subcategories, class_name: "Category", foreign_key: "category_id", dependent: :destroy
  belongs_to :category, class_name: "Category", optional: true
  has_many :products, dependent: :restrict_with_error
  has_many :subcategory_products, through: :subcategories, source: :products

  validates :name, presence: true
  validates :name, uniqueness: true, unless: -> { category_id? },
    allow_nil: true
  validates :name, uniqueness: { scope: :category_id }, allow_nil: true
  validate :single_level_nesting

  private def single_level_nesting
    if subcategories.any?
      self.subcategories.each do |s|
        if s.subcategories.any?
          errors.add(:base, "cannot add category to a root category having subcategories")
          return
        end
      end
    end

    errors.add(:base, "subcategory cannot have any child category") if subcategories.any? && category_id?

    errors.add(:base, "cannot add subcategory to a subcategory") if category_id? && category.category_id?
  end
end
