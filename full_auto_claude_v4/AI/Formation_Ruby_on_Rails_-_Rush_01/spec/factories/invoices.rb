FactoryBot.define do
  factory :invoice do
    project { nil }
    invoice_type { "MyString" }
    intro { "MyText" }
    total { "9.99" }
    status { "MyString" }
  end
end
