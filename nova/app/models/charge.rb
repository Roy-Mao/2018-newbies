# frozen_string_literal: true

class Charge < ApplicationRecord
  MIN_REMIT_AMOUNT = 50
  MAX_REMIT_AMOUNT = 100_000
  belongs_to :user

  validates :amount, numericality: { greater_than_or_equal_to: MIN_REMIT_AMOUNT, less_than_or_equal_to: MAX_REMIT_AMOUNT, only_integer: true }, presence: true

  after_create :create_stripe_charge

  protected

  def create_stripe_charge
    Stripe::Charge.create(
      amount: amount,
      currency: 'jpy',
      customer: user.stripe_id
    )

    user.update!(amount: user.amount + amount)
  rescue Stripe::StripeError => e
    errors.add(:user, e.code.to_s.to_sym)
    throw :abort
  end
end
