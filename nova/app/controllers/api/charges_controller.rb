# frozen_string_literal: true

class Api::ChargesController < Api::ApplicationController
  def index
    @charges = current_user.charges.order(id: :desc).limit(50)

    render json: { charges: @charges.as_json(only: [:amount, :created_at, :accepted_at]) }
  end

  def create
    @charge = current_user.charges.create!(amount: params[:amount])

    render json: @charge, status: :created
  end
end
