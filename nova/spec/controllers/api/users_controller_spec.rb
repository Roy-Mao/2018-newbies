# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'


RSpec.describe Api::UsersController, type: :controller do
  let(:user) { create(:user, :with_activated) }

  describe 'GET #show' do
    subject { get :show }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:ok) }
    end


    context 'response' do
      before do 
        login!(user)
        get :show
        @json = JSON.parse(response.body)
      end

      it 'include user' do
        expect(@json).to have_key('nickname')
        expect(@json).to have_key('email')
        expect(@json).to have_key('amount')
      end

      it 'not include user' do
        expect(@json).not_to have_key('id')
        expect(@json).not_to have_key('stripe_id')
        expect(@json).not_to have_key('activated')
        expect(@json).not_to have_key('password_digest')
        expect(@json).not_to have_key('activation_digest')
        expect(@json).not_to have_key('reset_digest')
      end
    end
  end

  describe 'PUT #update' do
    let(:user_params) { { user: {} } }
    subject { put :update, params: user_params }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      context 'with invalid params' do
        let(:user_params) { {} }

        it { is_expected.to have_http_status(:unprocessable_entity) }
      end

      context 'with invalid record params' do
        let(:user_params) { { user: { email: '' } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }
      end

      context 'with valid params' do
        let(:user_params) { { user: { nickname: 'John Doe' } } }

        it { is_expected.to have_http_status(:ok) }
      end
    end
  end
end
