# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :received_remit_requests, class_name: 'RemitRequest', foreign_key: :target_id, dependent: :destroy
  has_many :sent_remit_requests, class_name: 'RemitRequest', dependent: :destroy
  has_many :charges, dependent: :destroy
  has_one :credit_card, dependent: :destroy

  validates :nickname, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]{8,100}$\z/i
  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true, format: { with: VALID_PASSWORD_REGEX }

  def activated
    create_stripe_customer
  end


  def stripe
    return @stripe if instance_variable_defined?(:@stripe)

    @stripe = stripe_id? ? Stripe::Customer.retrieve(stripe_id) : nil
  end

  protected

  def create_stripe_customer
    return if stripe_id?

    customer = Stripe::Customer.create(
      email: email,
      description: "User: #{id}"
    )
    update(stripe_id: customer.id)
  rescue Stripe::StripeError => e
    errors.add(:stripe, e.code.to_s.to_sym)
    throw :abort
  end
end
