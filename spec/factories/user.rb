FactoryGirl.define do
  sequence :email do |n|
    "foo-#{n}@example.com"
  end
  
  sequence :name do |n|
    "Test User #{n}"
  end
  
  factory :user do
    name  { FactoryGirl.generate(:name) }
    email { FactoryGirl.generate(:email) }
    password "secret"
  end
  
end