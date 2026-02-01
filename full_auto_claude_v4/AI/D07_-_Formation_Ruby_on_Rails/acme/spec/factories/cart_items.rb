FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { 1 }
    unit_price { 19.99 }
  end
end
