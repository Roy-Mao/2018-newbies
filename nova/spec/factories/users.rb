# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    nickname { FFaker::Internet.user_name }
    email { FFaker::Internet.email }
    password "password123"
    password_confirmation "password123"
    confirmed_at Date.today

    trait :with_activated do
      after(:create) do |user|
        customer = Stripe::Customer.create( email: user.email, description: "User: #{user.id}" )
        user.update(stripe_id: customer.id)
      end
    end
  end
end
