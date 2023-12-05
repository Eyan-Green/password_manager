require 'faker'
FactoryBot.define do
  factory :user do
    pw = Devise.friendly_token[0, 20]
    email { Faker::Internet.email }
    password { pw }
    password_confirmation { pw }
    trait :user_password do
      after(:build) do |user|
        user.passwords << create(:password)
        user.user_passwords.last.role = 'Owner'
        user.save
      end
    end
  end
end
