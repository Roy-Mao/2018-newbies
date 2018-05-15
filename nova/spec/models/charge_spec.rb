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
end
