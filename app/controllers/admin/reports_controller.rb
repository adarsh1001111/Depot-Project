class Admin::ReportsController < Admin::BaseController

  def index
    @start_date = params[:start_date].presence || 5.days.ago.to_date
    @end_date = params[:end_date].presence || Date.current

    @orders = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                   .includes(:user, :line_items)
                   .order(created_at: :desc)
  end
end
