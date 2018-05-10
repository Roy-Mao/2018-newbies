# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    nickname { FFaker::Internet.user_name }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password }
  end

  trait :with_activated do
    activated { true }
    activated_at { Time.zone.now }
  end
end