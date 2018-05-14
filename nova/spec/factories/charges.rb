# frozen_string_literal: true

FactoryBot.define do
  factory :charge do
    user { build(:user, :with_activated) }
    amount 100
  end
end
