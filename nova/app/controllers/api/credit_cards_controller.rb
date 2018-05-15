# frozen_string_literal: true

class Api::CreditCardsController < Api::ApplicationController
  def show
    @credit_card = current_user.credit_card
    render json: @credit_card.as_json(only: :last4)
  end

  def create
    User.transaction do
      current_user.credit_card.try(:destroy)
      raise 'something wrong'
      @credit_card = CreditCard.create!(credit_card_params.merge(user: current_user))
      render json: @credit_card.as_json(only: %i[last4]), status: :created

      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.to_s }
        raise ActiveRecord::Rollback

      rescue ActiveRecord::ActiveRecordError => e
        render json: { error: e.to_s }
        raise ActiveRecord::Rollback

      rescue StandardError => e
        render json: { error: e.to_s }
        raise ActiveRecord::Rollback

      rescue Exception => e
        render json: { error: e.to_s }
        raise ActiveRecord::Rollback
    end

  end

  protected

  def credit_card_params
    params.require(:credit_card).permit(:source)
  end
end
