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

      it 'include nickname' do expect(@json.include?("nickname")).to eq true end
      it 'include email'    do expect(@json.include?("email")).to eq true end
      it 'include amount'   do expect(@json.include?("amount")).to eq true end

      it 'not include id'                do expect(@json.include?("id")).to eq false end
      it 'not include stripe_id'         do expect(@json.include?("stripe_id")).to eq false end
      it 'not include activated'         do expect(@json.include?("activated")).to eq false end
      it 'not include password_digest'   do expect(@json.include?("password_digest")).to eq false end
      it 'not include activation_digest' do expect(@json.include?("activation_digest")).to eq false end
      it 'not include reset_digest'      do expect(@json.include?("reset_digest")).to eq false end

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
