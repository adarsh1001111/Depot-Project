class ApplicationController < ActionController::Base
  before_action :set_i18n_locale_from_params
  before_action :set_start_time
  before_action :increment_hit_counter
  after_action :set_response_time_header

  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include ActiveStorage::SetCurrent

  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        I18n.locale = params[:locale]
      else
        flash.now[:notice] =
          "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
  end

  private

  def set_start_time
    @start_time = Time.now
  end

  def increment_hit_counter
    session[:hit_count] ||= 0
    session[:hit_count] += 1
  end

  def set_response_time_header
    response.headers["x-responded-in"] = "#{(Time.now - @start_time) * 1000}ms" if @start_time
  end
end
