Spree::Sample.load_sample('option_values')
Spree::Sample.load_sample('products')

product = Spree::Product.find_by!(name: 'Denim Shirt')
size = Spree::OptionValue.find_by!(name: 'xs')
color = Spree::OptionValue.find_by!(name: 'red')
eligible_values = "#{size.id},#{color.id}"

promotion = Spree::Promotion.where(
  name: 'free shipping',
  usage_limit: nil,
  path: nil,
  match_policy: 'any',
  description: '',
  code: 'FREESHIP'
).first_or_create! do |promo|
  promo.stores = Spree::Store.all
end

Spree::PromotionRule.where(
  promotion: promotion,
  type: 'Spree::Promotion::Rules::OptionValue',
  preferences: { match_policy: 'any', eligible_values: { product.id.to_s => eligible_values } }
).first_or_create!

Spree::Promotion::Actions::FreeShipping.where(promotion: promotion).first_or_create!
