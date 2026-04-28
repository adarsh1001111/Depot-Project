class RatingsController < ApplicationController
  before_action :set_product

  def create
    @rating = Rating.find_or_initialize_by(user: Current.user, product: @product)
    @rating.value = rating_params[:value]

    if @rating.save
      render json: {
        success: true,
        message: t("ratings.messages.saved"),
        average_rating: @product.average_rating,
        user_rating: @rating.value.to_f
      }
    else
      render json: {
        success: false,
        message: t("ratings.messages.failed"),
        errors: @rating.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.find(params.expect(:product_id))
  end

  def rating_params
    params.expect(rating: [ :value ])
  end
end
