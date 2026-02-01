FactoryBot.define do
  factory :client do
    first_name { "MyString" }
    last_name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    company { nil }
    position { "MyString" }
    user { nil }
  end
end
