module ProductsHelper
  def category_options_for_select
    categories = Category.includes(:category).order(:name)
    categories.map do |category|
      label = category.category.present? ? "#{category.category.name} > #{category.name}" : category.name
      [label, category.id]
    end
  end
end
