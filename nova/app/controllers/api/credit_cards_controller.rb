# frozen_string_literal: true

class Api::CreditCardsController < Api::ApplicationController
  def show
    @credit_card = current_user.credit_card
    render json: @credit_card.as_json(only: :last4)
  end

  def create
    current_user.credit_card.try(:destroy)
    @credit_card = CreditCard.create!(credit_card_params.merge(user: current_user))

    render json: @credit_card.as_json(only: :last4), status: :created
  end

  protected

  def credit_card_params
    params.require(:credit_card).permit(:source)
  end
end
