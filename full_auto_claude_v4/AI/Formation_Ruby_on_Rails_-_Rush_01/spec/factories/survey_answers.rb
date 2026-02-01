FactoryBot.define do
  factory :survey_answer do
    survey_response { nil }
    survey_question { nil }
    answer { false }
  end
end
