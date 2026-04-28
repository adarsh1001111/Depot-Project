class AdminController < Admin::BaseController
  def index
    @total_orders = Order.count
  end
end
