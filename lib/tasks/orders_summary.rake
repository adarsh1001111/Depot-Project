namespace :orders do
  desc "Send consolidated order summary email to all users"
  task send_consolidated_summaries: :environment do
    users = User.includes(orders: { line_items: :product }).where.not(email_address: nil)

    users.find_each do |user|
      OrderMailer.consolidated_summary(user).deliver_now
    end
  end
end
