FactoryBot.define do
  factory :customer do
    first_name { Faker::Games::DnD.first_name }
    last_name  { Faker::Games::DnD.last_name }
  end
end
