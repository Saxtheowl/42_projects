FactoryBot.define do
  factory :order do
    project { nil }
    intro { "MyText" }
    total { "9.99" }
    status { "MyString" }
  end
end
