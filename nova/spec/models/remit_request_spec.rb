# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemitRequest, type: :model do
  subject(:remit_request) { build(:remit_request) }

  it { is_expected.to be_valid }

  statuses = %i[outstanding accepted rejected canceled]
  statuses.each do |status|
    context "with #{status}" do
      let(:remit_request) { create(:remit_request, status) }

      it("should record status be #{status}") { expect(RemitRequest.send(status)).to include(remit_request) }
    end
  end
end
