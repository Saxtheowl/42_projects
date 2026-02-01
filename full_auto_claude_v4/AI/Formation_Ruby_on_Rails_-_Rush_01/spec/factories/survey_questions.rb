FactoryBot.define do
  factory :survey_question do
    survey { nil }
    question { "MyString" }
  end
end
