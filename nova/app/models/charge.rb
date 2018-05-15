# frozen_string_literal: true

class Charge < ApplicationRecord
  MIN_CHARGE_AMOUNT = 50
  MAX_CHARGE_AMOUNT = 100_000
  belongs_to :user

  validates :amount, numericality: { greater_than_or_equal_to: MIN_CHARGE_AMOUNT, less_than_or_equal_to: MAX_CHARGE_AMOUNT, only_integer: true }, presence: true

  enum status: { outstanding: 0, accepted: 1, standing: 2}
  after_create :create_stripe_charge

  protected

  def create_stripe_charge
    response = Stripe::Charge.create(
      amount: amount,
      currency: 'jpy',
      customer: user.stripe_id,
      capture: false,
    )

    # Stripe::Chargeが正常に動作したら

    user.update!(amount: user.amount + amount)
    charge = Stripe::Charge.retrieve(response["id"])
    charge.capture
    self.update!(status: :accepted, stripe_id: response.id)
  rescue Stripe::StripeError => e
    errors.add(:user, e.code.to_s.to_sym)
    self.update!(status: :standing)
  end
end
