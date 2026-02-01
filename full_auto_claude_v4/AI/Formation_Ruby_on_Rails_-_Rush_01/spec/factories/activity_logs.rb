FactoryBot.define do
  factory :activity_log do
    user { nil }
    action { "MyString" }
    trackable { nil }
    details { "MyText" }
  end
end
