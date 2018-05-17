# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charge, type: :model do
  describe 'validation' do
    subject(:charge) { build(:charge, amount: amount) }

    context "50以下の場合" do
      let(:amount) { 49 }
      it { is_expected.not_to be_valid }
    end

    context "50の場合" do
      let(:amount) { 50 }
      it { is_expected.to be_valid }
    end

    context "50以上の場合" do
      let(:amount) { 51 }
      it { is_expected.to be_valid }
    end

    context "100000以上の場合" do
      let(:amount) { 100001 }
      it { is_expected.not_to be_valid }
    end

    context "100000の場合" do
      let(:amount) { 100000 }
      it { is_expected.to be_valid }
    end

    context "100000以下の場合" do
      let(:amount) { 99999 }
      it { is_expected.to be_valid }
    end
  end

  describe 'charge value' do
    context 'not registrated creditcard' do
      let(:user) { create(:user, amount: 0) }
      subject(:charge) { create(:charge, amount: 100, user: user) }
      it do
        expect(charge.status).to eq 'standing'
        expect(charge.user.amount).to eq 0
      end
    end

    context 'registrated creditcard' do
      let(:user) { create(:user, :with_registrated_stripe, amount: 0) }
      subject(:charge) { create(:charge, amount: 100, user: user) }
      it do
        expect(charge.status).to eq 'accepted'
        expect(charge.user.amount).to eq 100
      end
    end
  end

  describe 'enum status' do
    context 'outstanding' do
      let(:charge) { build(:charge) }

      it do expect(charge.status).to eq "outstanding" end
    end

    context 'accepted' do
      let(:charge) { build(:charge, status: 1) }

      it do expect(charge.status).to eq "accepted" end
    end

    context 'rejected' do
      let(:charge) { build(:charge, status: 2) }

      it do expect(charge.status).to eq "standing" end
    end
  end
end
