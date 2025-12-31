class User < ApplicationRecord
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/.freeze
  validates :name, presence: true, uniqueness: true
  validates :email_address, presence: true, uniqueness: true
  validates :email, uniqueness: true, format: { with: EMAIL_REGEX }

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  after_destroy :ensure_an_admin_remains

  class Error < StandardError
  end

  private
    def ensure_an_admin_remains
      if User.count.zero?
        raise Error.new "Can't delete last user"
      end
    end
end
