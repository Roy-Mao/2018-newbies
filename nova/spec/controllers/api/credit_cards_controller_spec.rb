# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CreditCardsController, type: :controller do
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

    context 'check response' do
      before do 
        login!(user)
        create(:credit_card, user_id: user.id, source: stripe.generate_card_token)
        get :show
        @json = JSON.parse(@response.body)
      end

      it 'include credit_card' do
        expect(@json).to have_key('last4')
      end

      it 'not include credit_card' do
        expect(@json).not_to have_key('brand')
        expect(@json).not_to have_key('user_id')
        expect(@json).not_to have_key('exp_year')
        expect(@json).not_to have_key('exp_month')
        expect(@json).not_to have_key('stripe_id')
      end

    end
  end

  describe 'POST #create' do
    subject { post :create, params: { credit_card: { source: stripe.generate_card_token } } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before { login!(user) }

      it { is_expected.to have_http_status(:created) }
    end
  end
end
