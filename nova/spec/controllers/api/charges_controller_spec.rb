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
        @charge = JSON.parse(response.body)["charges"][0]
      end

      it 'include amount' do expect(@charge.include?("amount")).to eq true end
      it 'include created_at' do expect(@charge.include?("created_at")).to eq true end
      #[TODO] accepted_at -> statusに変更する予定
      xit 'include accepted_at' do expect(@charge.include?("accepted_at")).to eq true end

      it 'not include id' do expect(@charge.include?("id")).to eq false end
      it 'not include user_id' do expect(@charge.include?("user_id")).to eq false end

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
