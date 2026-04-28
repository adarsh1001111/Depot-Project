class CategoriesController < ApplicationController
  def books
    @category = Category.find(params[:id])
    category_ids = [ @category.id ] + @category.subcategories.pluck(:id)
    @books = Product.where(category_id: category_ids).includes(:category)
  rescue ActiveRecord::RecordNotFound
    redirect_to store_index_path, alert: "Category not found"
  end
end
