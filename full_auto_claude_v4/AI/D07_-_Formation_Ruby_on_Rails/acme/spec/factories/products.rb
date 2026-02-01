FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { "A great product description" }
    price { 19.99 }
    association :brand
  end
end
