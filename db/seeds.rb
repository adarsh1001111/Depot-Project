# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


LineItem.delete_all
LineItem.delete_all
Product.delete_all

product1 = Product.new(
  title: 'Professional DSLR Camera Kit',
  description: 'High quality DSLR camera with advanced features',
  price: 599.99,
  discount_price: 549.99,
  permalink: 'professional-dslr-camera-kit',
  image_url: 'https://example.com/camera.webp'
)
product1.images.attach(io: File.open(Rails.root.join('db', 'images', 'camera.webp')), filename: 'camera.webp')
product1.save!

product2 = Product.new(
  title: 'Elegant Wristwatch for Adults',
  description: 'Stylish wristwatch perfect for formal occasions',
  price: 199.99,
  discount_price: 179.99,
  permalink: 'elegant-wristwatch-adults',
  image_url: 'https://example.com/watch.jpeg'
)
product2.images.attach(io: File.open(Rails.root.join('db', 'images', 'pexels-javon-swaby-197616-2783873.jpg')), filename: 'watch.jpg')
product2.save!

product3 = Product.new(
  title: 'Refreshing Coca-Cola Beverage',
  description: 'Classic carbonated drink for thirst quenching',
  price: 2.99,
  discount_price: 2.49,
  permalink: 'refreshing-coca-cola-beverage',
  image_url: 'https://example.com/coke.png'
)
product3.images.attach(io: File.open(Rails.root.join('db', 'images', 'pexels-olenkabohovyk-3819969.jpg')), filename: 'coke.jpg')
product3.save!
