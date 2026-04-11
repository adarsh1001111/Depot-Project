class User < ApplicationRecord
  has_many :orders, dependent: :destroy
  DEPOT_ADMIN_MAIL = "admin@depot.com".freeze
  EMAIL_REGEX = /\A[\w._%+-]+@[\w.-]+\.[a-zA-Z]{2,}\z/.freeze
  validates :name, presence: true, uniqueness: true
  validates :email_address, presence: true, uniqueness: true
  validates :email, uniqueness: true, format: { with: EMAIL_REGEX }

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :line_items, through: :orders

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  after_destroy :ensure_an_admin_remains

  after_commit :send_mail

  before_destroy :check_depot_admin
  before_update :check_depot_admin

  class Error < StandardError
  end

  private def check_depot_admin
    Rails.logger.info("Depot_Admin user with email: #{email} can't be updated or destroyed")
    throw :abort if email == DEPOT_ADMIN_MAIL
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
