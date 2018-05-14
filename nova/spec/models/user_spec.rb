# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'User' do
    subject(:user) { create(:user) }

    context 'validate' do
      it { is_expected.to be_valid }

      context 'email' do
        let (:email) { "LARGE@MAIL.COM" }
        let (:user) {create(:user, email: email)}
        it { expect(user.email).to eq email.downcase }
      end
    end

    #TODO: modelのテストをかく
    context 'association' do
      context 'sent_remit_requests' do
        before { create(:remit_request, user: user)}
        it 'create sent_remit_requests' do
          expect(user.sent_remit_requests.count).to eq 1
        end
      end

      context 'received_remit_requests' do
        before { create(:remit_request, target: user)}
        it 'create received_remit_requests' do
          expect(user.received_remit_requests.count).to eq 1
        end
      end
      
      context 'charges' do
        before { create(:charge, user_id: user.id)}
        it 'create charges' do
          expect(user.charges.count).to eq 1
        end
      end
      context 'credit_card' do
        before { create(:credit_card, user_id: user.id, source: stripe.generate_card_token)}
        it 'create credit_card' do
          expect(user.credit_card).not_to eq nil
        end
      end
    end
  end
end
