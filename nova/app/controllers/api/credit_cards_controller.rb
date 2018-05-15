# frozen_string_literal: true

class Api::CreditCardsController < Api::ApplicationController
  def show
    @credit_card = current_user.credit_card
    render json: @credit_card.as_json(only: :last4)
  end

  def create
    User.transaction do
      current_user.credit_card.try(:destroy)
      raise 'something happened here'
      @credit_card = CreditCard.create!(credit_card_params.merge(user: current_user))
      render json: @credit_card.as_json(only: %i[last4]), status: :created
      
      rescue ActiveRecord::RecordNotFound => e
        raise ActiveRecord::Rollback, "RecordNotFound"

      rescue ActiveRecord::ActiveRecordError => e
        raise ActiveRecord::Rollback, "ActiveRecordError"

      rescue StandardError => e
        raise ActiveRecord::Rollback, "StandardError"

      rescue Exception => e
        raise ActiveRecord::Rollback, "SpecialError"
    end

  end

  protected

  def credit_card_params
    params.require(:credit_card).permit(:source)
  end
end
