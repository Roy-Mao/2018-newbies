# frozen_string_literal: true

class Api::RemitRequestsController < Api::ApplicationController
  def index
    all_remit_requests = RemitRequest.where("(user_id = ?) OR (target_id = ?)", current_user.id, current_user.id)
    @remit_requests = all_remit_requests.page(params[:page])
    remit_requests_count = all_remit_requests.count

    page_limit = [@remit_requests.count, 1].max
    pages = [remit_requests_count, 1].max / page_limit + 
      ( remit_requests_count % page_limit ? 0 : 1)

    render json:{
        max_pages: pages,
        amount: current_user.amount,
        remit_requests: 
          @remit_requests.as_json(include: {
          user: { only: :email },
          target: { only: :email }
        },only: [:amount, :status, :id] ).to_a
      }
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

    render json: {amount: @remit_request.change_status_accept}, status: :ok
  end

  def reject
    @remit_request = RemitRequest.find(params[:id])
    @remit_request.update!(status: :rejected) if @remit_request.status == 'outstanding'

    render json: {}, status: :ok
  end

  def cancel
    @remit_request = RemitRequest.find(params[:id])
    @remit_request.update!(status: :canceled) if @remit_request.status == 'outstanding'

    render json: {}, status: :ok
  end
end
