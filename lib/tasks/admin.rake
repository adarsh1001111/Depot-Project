namespace :admin do
  desc "Mark a user as admin by email"
  task :make_admin, [ :email ] => :environment do |t, args|
    if args[:email].blank?
      puts "Usage: rake admin:make_admin[email@example.com]"
      exit 1
    end

    user = User.find_by(email_address: args[:email])
    if user.nil?
      puts "User with email #{args[:email]} not found"
      exit 1
    end

    user.update(role: "admin")
    puts "User #{user.email_address} has been marked as admin"
  end
end
