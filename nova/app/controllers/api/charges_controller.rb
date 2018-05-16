# frozen_string_literal: true

class Api::ChargesController < Api::ApplicationController
  def index
    @charges = current_user.charges.order(id: :desc).limit(50)

    render json: { charges: @charges.as_json(only: [:amount, :created_at, :status]) }
  end

  def create
    begin
      @charge = current_user.charges.create!(amount: params[:amount])

      render json: @charge, status: :created
    rescue => e
      render json: @charge, status: :service_unavailable
    end
  end
end
