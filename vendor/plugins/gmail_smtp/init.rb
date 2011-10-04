require 'factory_girl'

Factory.define :user do |u|
  u.sequence(:name) { |n| "Test User #{n}" }
  u.sequence(:email) { |n| "foo-#{n}@example.com" }
  u.password "secret"
  u.newsletter 1
end