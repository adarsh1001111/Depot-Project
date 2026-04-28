class Admin::CategoriesController < Admin::BaseController

  def index
    @categories = Category.all.includes(:products)
  end
end
