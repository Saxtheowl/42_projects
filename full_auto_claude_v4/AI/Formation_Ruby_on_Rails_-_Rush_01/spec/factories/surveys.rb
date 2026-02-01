FactoryBot.define do
  factory :survey do
    title { "MyString" }
    intro { "MyText" }
    thank_you { "MyText" }
    user { nil }
    published { false }
  end
end
