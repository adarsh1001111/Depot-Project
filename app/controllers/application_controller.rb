class ApplicationController < ActionController::Base
  before_action :set_i18n_locale_from_params
  before_action :set_start_time
  before_action :increment_hit_counter
  after_action :set_response_time_header

  include Authentication
  include ActiveStorage::SetCurrent

  def set_i18n_locale_from_params
    requested_locale = params[:locale].presence || Current.user&.language || I18n.default_locale
    requested_locale = requested_locale.to_s

    if I18n.available_locales.map(&:to_s).include?(requested_locale)
      I18n.locale = requested_locale
    else
      I18n.locale = I18n.default_locale
      flash.now[:notice] = I18n.t("flash.application.translation_not_available", locale: requested_locale)
      logger.error flash.now[:notice]
    end
  end

  def default_url_options
    { locale: I18n.locale }
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
