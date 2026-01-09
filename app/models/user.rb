class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :email_address, presence: true, uniqueness: true
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  after_destroy :ensure_an_admin_remains

  after_create :send_mail

  before_destroy :check_depot_admin
  before_update :check_depot_admin

  class Error < StandardError
  end

  private def check_depot_admin
    Rails.logger.info("Depot_Admin user with email: #{email} can't be updated or destroyed")
    throw :abort if email == "admin@depot.com"
  end

  private def send_mail
    Rails.logger.info("Welcome #{email}")
  end

  private def ensure_an_admin_remains
    if User.count.zero?
      raise Error.new "Can't delete last user"
    end
  end
end
