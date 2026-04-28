class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    unless authenticated? && Current.user&.role == "admin"
      redirect_to store_index_path, alert: t("flash.admin.not_authorized")
    end
  end
end
