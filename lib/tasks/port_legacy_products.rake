desc "Assign legacy products without a category to the first category"
task port_legacy_products: :environment do
  category = Category.first
  raise "No categories exist. Create at least one category before porting products." unless category

  legacy_products = Product.where(category_id: nil)
  legacy_products.find_each do |product|
    product.update!(category: category)
  end

  puts "Assigned #{legacy_products.count} legacy products to category '#{category.name}'."
end
