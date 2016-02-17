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

  describe 'reserve!' do
    let(:start_datetime) { Date.yesterday.to_datetime }
    let(:end_datetime) { Date.tomorrow.to_datetime }
    let(:item) { create :item }
    let(:call) { item.reserve! start_datetime, end_datetime }
    it 'creates a reservation for the item' do
      expect { call }.to change { Reservation.count }.by 1
      reservation = Reservation.last
      expect(reservation.item).to eql item
    end
  end
end
