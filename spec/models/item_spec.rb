require 'rails_helper'

describe Item do
  describe 'available_between' do
    let(:start_datetime) { Date.yesterday.to_datetime }
    let(:end_datetime) { Date.tomorrow.to_datetime }
    let(:call) { Item.available_between start_datetime, end_datetime }
    let!(:item) { create :item }
    it 'calls Reservation.during' do
      expect(Reservation)
        .to receive(:during)
        .with(start_datetime, end_datetime)
        .and_return Reservation.none
      call
    end
    it 'includes an item with no reservations' do
      expect(call).to include item
    end
  end
end
