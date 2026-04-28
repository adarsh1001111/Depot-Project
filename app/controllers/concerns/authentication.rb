module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :check_session_timeout
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def check_session_timeout
      if authenticated? && session_timed_out?
        terminate_session
        redirect_to new_session_path, alert: I18n.t("flash.authentication.session_expired")
      end
    end

    def session_timed_out?
      return false unless Current.session
      Current.session.updated_at < 5.minutes.ago
    end

    def resume_session
      Current.session ||= find_session_by_cookie&.tap do |session|
        session.touch # Update updated_at to track activity
      end
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      if Current.user&.role == "admin"
        admin_reports_path
      else
        session.delete(:return_to_after_authenticating) || store_index_path
      end
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
