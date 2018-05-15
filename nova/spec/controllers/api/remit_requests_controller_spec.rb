# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RemitRequestsController, type: :controller do
  let(:user) { create(:user, :with_activated) }
  let(:target) { create(:user, :with_activated) }
  let(:remit_request) { create(:remit_request, target: user) }

  describe 'GET #index' do
    context 'without page params' do
      subject { get :index }

      context 'without logged in' do
        it { is_expected.to have_http_status(:unauthorized) }
      end

      context 'with logged in' do
        before { login!(user) }

        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'with page params' do
      subject { get :index, params: { pages: 1 } }

      context 'without logged in' do
        it { is_expected.to have_http_status(:unauthorized) }
      end

      context 'with logged in' do
        before { login!(user) }

        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'check response' do
      before do 
        login!(user)
        create(:remit_request, target: user)
        get :index
        @json = JSON.parse(response.body)
      end

      context 'response' do
        it 'include max_pages' do expect(@json.include?("max_pages")).to eq true end
        it 'include remit_requests' do expect(@json.include?("remit_requests")).to eq true end
        context 'remit_request' do
          before do @remit_request = @json["remit_requests"].first end
          it 'include remit_request.status' do expect(@remit_request.include?("status")).to eq true end
          it 'include remit_request.amount' do expect(@remit_request.include?("amount")).to eq true end

          it 'not include remit_request.id' do expect(@remit_request.include?("id")).to eq false end
          it 'not include remit_request.user_id' do expect(@remit_request.include?("user_id")).to eq false end
          it 'not include remit_request.target_id' do expect(@remit_request.include?("target_id")).to eq false end

          context 'user' do
            it 'include user.email' do expect(@remit_request["user"].include?("email")).to eq true end

            it 'include user.id' do expect(@remit_request["user"].include?("id")).to eq false end
            it 'not include user.nicgkname' do expect(@remit_request["user"].include?("nickname")).to eq false end
            it 'not include user.stripe_id' do expect(@remit_request["user"].include?("stripe_id")).to eq false end
            it 'not include user.activated' do expect(@remit_request["user"].include?("activated")).to eq false end
            it 'not include user.password_digest' do expect(@remit_request["user"].include?("password_digest")).to eq false end
            it 'not include user.activation_digest' do expect(@remit_request["user"].include?("activation_digest")).to eq false end
            it 'not include user.reset_digest' do expect(@remit_request["user"].include?("reset_digest")).to eq false end
            it 'not include user.amount' do expect(@remit_request["user"].include?("amount")).to eq false end
          end

          context 'target' do
            it 'include target.email' do expect(@remit_request["target"].include?("email")).to eq true end
            it 'include target.id' do expect(@remit_request["target"].include?("id")).to eq false end
            it 'not include target.nickname' do expect(@remit_request["target"].include?("nickname")).to eq false end
            it 'not include target.stripe_id' do expect(@remit_request["target"].include?("stripe_id")).to eq false end
            it 'not include target.activated' do expect(@remit_request["target"].include?("activated")).to eq false end
            it 'not include target.password_digest' do expect(@remit_request["target"].include?("password_digest")).to eq false end
            it 'not include target.activation_digest' do expect(@remit_request["target"].include?("activation_digest")).to eq false end
            it 'not include target.reset_digest' do expect(@remit_request["target"].include?("reset_digest")).to eq false end
            it 'not include target.amount' do expect(@remit_request["target"].include?("amount")).to eq false end
          end
        end
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { emails: [target.email], amount: 3000 } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:created) }
    end
  end

  describe 'POST #accept' do
    subject { post :accept, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #reject' do
    subject { post :reject, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #cancel' do
    subject { post :cancel, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:ok) }
    end
  end
end
