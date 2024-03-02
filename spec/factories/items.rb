FactoryBot.define do
  factory :item do
    name { Faker::Games::Minecraft.item }
    description { Faker::HitchhikersGuideToTheGalaxy.quote }
    unit_price { Faker::Number.between(from: 10000, to: 100000) }
    association :merchant
  end
end
