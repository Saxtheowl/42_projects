FactoryBot.define do
  factory :line_item do
    itemable { nil }
    description { "MyString" }
    price { "9.99" }
    quantity { 1 }
  end
end
