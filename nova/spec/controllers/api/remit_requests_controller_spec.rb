# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RemitRequestsController, type: :controller do
  let(:sender) { create(:user, :with_activated) }
  let(:receiver) { create(:user, :with_activated) }
  let(:amount) { 100 }
  let(:remit_request) { create(:remit_request, user: sender, target: receiver, amount: amount) }

  describe 'GET #index' do
    context 'without page params' do
      subject { get :index }

      context 'without logged in' do
        it { is_expected.to have_http_status(:unauthorized) }
      end

      context 'with logged in' do
        before { sign_in(receiver) }

        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'with page params' do
      subject { get :index, params: { pages: 1 } }

      context 'without logged in' do
        it { is_expected.to have_http_status(:unauthorized) }
      end

      context 'with logged in' do
        before { sign_in(receiver) }

        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'check response' do
      before do
        sign_in user
        create(:remit_request, target: user)
        get :index
        @json = JSON.parse(response.body)
      end

      it 'include response' do
        expect(@json).to have_key('max_pages')
        expect(@json).to have_key('remit_requests')
      end

      it 'not include response' do
        expect(@json).not_to have_key('user_id')
        expect(@json).not_to have_key('stripe_id')
      end

      context 'remit_request' do
        before do @remit_request = @json["remit_requests"].first end
        it 'include remit_request' do
          expect(@remit_request).to have_key('status')
          expect(@remit_request).to have_key('amount')
          expect(@remit_request).to have_key('id')
        end

        it 'not include remit_request' do
          expect(@remit_request).not_to have_key('user_id')
          expect(@remit_request).not_to have_key('target_id')
        end

        context 'user' do
          it 'include user' do
            expect(@remit_request["user"]).to have_key('email')
          end

          it 'not include user' do
            expect(@remit_request["user"]).not_to have_key('id')
            expect(@remit_request["user"]).not_to have_key('nickname')
            expect(@remit_request["user"]).not_to have_key('stripe_id')
            expect(@remit_request["user"]).not_to have_key('activated')
            expect(@remit_request["user"]).not_to have_key('password_digest')
            expect(@remit_request["user"]).not_to have_key('activation_digest')
            expect(@remit_request["user"]).not_to have_key('reset_digest')
            expect(@remit_request["user"]).not_to have_key('amount')
          end
        end
        context 'target' do
          it 'include target' do
            expect(@remit_request["target"]).to have_key('email')
          end

          it 'not include target' do
            expect(@remit_request["target"]).not_to have_key('id')
            expect(@remit_request["target"]).not_to have_key('nickname')
            expect(@remit_request["target"]).not_to have_key('stripe_id')
            expect(@remit_request["target"]).not_to have_key('activated')
            expect(@remit_request["target"]).not_to have_key('password_digest')
            expect(@remit_request["target"]).not_to have_key('activation_digest')
            expect(@remit_request["target"]).not_to have_key('reset_digest')
            expect(@remit_request["target"]).not_to have_key('amount')
          end
        end
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { emails: [receiver.email], amount: 3000 } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(receiver) }

      it { is_expected.to have_http_status(:created) }
    end
  end

  describe 'POST #accept' do

    context 'without logged in' do
      subject { post :accept, params: { id: remit_request.id } }
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(receiver) }

      it { is_expected.to have_http_status(:ok) }
      it { expect(@json["amount"]).to eq amount }
    end
  end

  describe 'POST #reject' do
    subject { post :reject, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(receiver) }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #cancel' do
    subject { post :cancel, params: { id: remit_request.id } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { sign_in(receiver) }

      it { is_expected.to have_http_status(:ok) }
    end
  end
end
