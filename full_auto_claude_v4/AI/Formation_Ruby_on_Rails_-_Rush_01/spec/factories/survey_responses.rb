FactoryBot.define do
  factory :survey_response do
    survey { nil }
    email { "MyString" }
    user { nil }
  end
end
