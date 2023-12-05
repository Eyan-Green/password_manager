FactoryBot.define do
  factory :password do
    url { 'https://twitter.com' }
    password { 'Password' }
    username { 'Username' }
  end
end
