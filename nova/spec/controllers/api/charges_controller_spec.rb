# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ChargesController, type: :controller do
  let(:user) { create(:user, :with_activated) }

  describe 'GET #index' do
    subject { get :index }

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
        create(:charge, {user_id: user.id})
        get :index
        @json = JSON.parse(response.body)["charges"][0]
      end

      it 'include charges' do
        expect(@json).to have_key('amount')
        expect(@json).to have_key('created_at')
      end

      it 'not include charges' do
        expect(@json).not_to have_key('id')
        expect(@json).not_to have_key('user_id')
        expect(@json).not_to have_key('stripe_id')
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { amount: 3000 } }

    context 'without logged in' do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with logged in' do
      before do
        create(:credit_card, user: user, source: stripe.generate_card_token)
        login!(user)
      end

      it { is_expected.to have_http_status(:created) }
    end
  end
end
