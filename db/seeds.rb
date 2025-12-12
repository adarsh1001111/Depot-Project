# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


Product.delete_all
# . . .
product1 = Product.create(title: 'Camera',
    description:
        %(<p>
            <em>Click pictures</em>
            Good Camera!
        </p>),
    price: 30.95)

product2 = Product.create(title: 'Watch',
    description:
        %(<p>
            <em>Watch TIme</em>
            Good Watch!
        </p>),
    price: 40)

product3 = Product.create(title: 'Coca-Cola',
    description:
        %(<p>
            <em>Drink Chilled!</em>
            Coca-Cola
        </p>),
    price: 3)

product1.image.attach(io: File.open(
        Rails.root.join('db', 'images', 'camera.webp')
        ),
    filename: 'camera.webp')

product2.image.attach(io: File.open(
        Rails.root.join('db', 'images', 'pexels-javon-swaby-197616-2783873.jpg')
        ),
    filename: 'watch.jpg')

product3.image.attach(io: File.open(
        Rails.root.join('db', 'images', 'pexels-olenkabohovyk-3819969.jpg') # Actual file_name/path
        ),
    filename: 'coke.jpg') # ActiveStorage mei this would have this filename i think!!!

product1.save!
product2.save!
product3.save!
