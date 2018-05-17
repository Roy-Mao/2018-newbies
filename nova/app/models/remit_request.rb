# frozen_string_literal: true

class RemitRequest < ApplicationRecord
  MIN_REMIT_AMOUNT = 1

  validates :amount, numericality: { greater_than_or_equal_to: MIN_REMIT_AMOUNT, only_integer: true }, presence: true

  belongs_to :user
  belongs_to :target, class_name: 'User'

  validates :amount, numericality: { greater_than: 0 }
  paginates_per 10

  enum status: { outstanding: 0, accepted: 1, rejected: 2, canceled: 3 }

  def change_status_accept
    enough_money = self.target.amount >= self.amount
    if self.status == 'outstanding' && enough_money 
      self.status = :accepted
      self.user.amount += self.amount
      self.target.amount -= self.amount
      self.save!
      self.user.save!
      self.target.save!
    end
    self.target.amount
  end

end
