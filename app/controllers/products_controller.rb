class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all

    respond_to do |format|
      format.html
      format.json do
        render json: @products.map { |product|
          {
            name: product.title,
            category: product.category&.name
          }
        }
      end
    end
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: t("flash.products.created") }
        format.json { render :show, status: :created, location: @product }
      else
        puts @product.errors.full_messages
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      # Handle images separately to append rather than replace
      product_params_hash = product_params.to_h
      if params[:product][:images].present?
        # Append new images to existing ones
        @product.images.attach(params[:product][:images])
        product_params_hash.delete(:images)
      end

      if @product.update(product_params_hash)
        format.html { redirect_to @product, notice: t("flash.products.updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @product }

        @product.broadcast_replace_later_to "store/products",
          partial: "store/product"
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, notice: t("flash.products.destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  # DELETE /products/1/remove_image
  def remove_image
    image = @product.images.find(params[:image_id])
    image.purge
    redirect_to edit_product_path(@product), notice: t("flash.products.image_removed")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [ :title, :description, :price, :discount_price,
        :enabled, :permalink, :image_url, :category_id ])
    end
end
