class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  before_action :add_process_id_header

  private

  def add_process_id_header
    headers["X-SYSTEM-PROCESS-ID"] = Process.pid.to_s
  end
end
