# frozen_string_literal: true

class Api::RemitRequestsController < Api::ApplicationController
  def index
    all = RemitRequest.where("(user_id = ?) OR (target_id = ?)", current_user.id, current_user.id)
    @remit_requests = all.page(params[:page])
    remit_requests_count = all.count

    page_limit = [@remit_requests.count, 1].max
    pages = [remit_requests_count, 1].max / page_limit + 
      ( remit_requests_count % page_limit ? 0 : 1)

    render json:{max_pages: pages, remit_requests: @remit_requests.as_json(include: [:user, :target] ).to_a}
  end

  def create
    params[:emails].each do |email|
      user = User.find_by(email: email)
      next unless user
      RemitRequest.create!(user: current_user, target: user, amount: params[:amount])
    end

    render json: {}, status: :created
  end

  def accept
    @remit_request = RemitRequest.find(params[:id])
    @remit_request.update!(accepted_at: Time.now)
    @remit_request.update!(status: :accepted)

    amount = current_user.amount - @remit_request.amount
    current_user.update(amount: amount)

    render json: {}, status: :ok
  end

  def reject
    @remit_request = RemitRequest.find(params[:id])
    @remit_request.update!(rejected_at: Time.now)
    @remit_request.update!(status: :rejected)

    render json: {}, status: :ok
  end

  def cancel
    @remit_request = RemitRequest.find(params[:id])
    @remit_request.update!(canceled_at: Time.now)
    @remit_request.update!(status: :canceled)

    render json: {}, status: :ok
  end
end
