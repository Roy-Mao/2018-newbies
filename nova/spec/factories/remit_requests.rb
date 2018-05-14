# frozen_string_literal: true

FactoryBot.define do
  factory :remit_request do
    user { build(:user, :with_activated) }
    target { build(:user, :with_activated) }
    amount 100

    trait :outstanding do
      status { :outstanding }
    end

    trait :accepted do
      status { :accepted }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :canceled do
      status { :canceled }
    end
  end
end
